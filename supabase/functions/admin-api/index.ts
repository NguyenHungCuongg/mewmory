import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";
import { createAdminClient } from "../_shared/admin-utils.ts";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
};

/** Verify caller is authenticated AND is_admin = true. Returns user_id or null. */
async function verifyAdmin(authHeader: string | null): Promise<string | null> {
  if (!authHeader) return null;
  try {
    const supabaseUrl = Deno.env.get("SUPABASE_URL")!;
    const supabaseAnonKey = Deno.env.get("SUPABASE_ANON_KEY")!;
    const anonClient = createClient(supabaseUrl, supabaseAnonKey);
    const token = authHeader.replace("Bearer ", "");
    const { data: { user }, error: authError } = await anonClient.auth.getUser(token);
    if (authError || !user) return null;

    const adminClient = createAdminClient();
    const { data: profile } = await adminClient
      .from("profiles")
      .select("is_admin")
      .eq("id", user.id)
      .single();
    if (!profile?.is_admin) return null;
    return user.id;
  } catch {
    return null;
  }
}

serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  const authHeader = req.headers.get("Authorization");
  const adminId = await verifyAdmin(authHeader);
  if (!adminId) {
    return new Response(JSON.stringify({ error: "Forbidden" }), {
      status: 403,
      headers: { ...corsHeaders, "Content-Type": "application/json" },
    });
  }

  const url = new URL(req.url);
  const action = url.searchParams.get("action");
  const adminClient = createAdminClient();

  try {
    if (action === "system_stats") {
      return await handleSystemStats(adminClient);
    }
    if (action === "list_users") {
      return await handleListUsers(adminClient);
    }
    if (action === "user_detail") {
      const userId = url.searchParams.get("user_id");
      if (!userId) {
        return new Response(JSON.stringify({ error: "user_id required" }), {
          status: 400,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        });
      }
      return await handleUserDetail(userId, adminClient);
    }
    if (action === "ban_user" && req.method === "POST") {
      const body = await req.json();
      return await handleBanUser(body.user_id, body.reason, adminClient);
    }
    if (action === "unban_user" && req.method === "POST") {
      const body = await req.json();
      return await handleUnbanUser(body.user_id, adminClient);
    }
    if (action === "unflag_user" && req.method === "POST") {
      const body = await req.json();
      return await handleUnflagUser(body.user_id, adminClient);
    }

    return new Response(JSON.stringify({ error: "Unknown action" }), {
      status: 400,
      headers: { ...corsHeaders, "Content-Type": "application/json" },
    });
  } catch (err) {
    console.error("[admin-api] error:", err);
    return new Response(JSON.stringify({ error: "Internal server error" }), {
      status: 500,
      headers: { ...corsHeaders, "Content-Type": "application/json" },
    });
  }
});

// ─── Handlers ────────────────────────────────────────────────────────────────

async function handleSystemStats(adminClient: any): Promise<Response> {
  const now = new Date();
  const todayStart = new Date(now.getFullYear(), now.getMonth(), now.getDate()).toISOString();
  const yesterday24h = new Date(now.getTime() - 24 * 60 * 60 * 1000).toISOString();

  const [
    { count: total_users },
    { count: active_today },
    { count: flagged_users },
    { count: banned_users },
    { count: api_calls_24h },
    { count: total_vocabularies },
    { data: hourlyRows },
  ] = await Promise.all([
    adminClient.from("profiles").select("id", { count: "exact", head: true }),
    adminClient.from("profiles").select("id", { count: "exact", head: true })
      .gte("last_active_at", todayStart),
    adminClient.from("profiles").select("id", { count: "exact", head: true })
      .eq("is_flagged", true),
    adminClient.from("profiles").select("id", { count: "exact", head: true })
      .eq("is_banned", true),
    adminClient.from("api_usage_logs").select("id", { count: "exact", head: true })
      .gte("created_at", yesterday24h),
    adminClient.from("vocabularies").select("id", { count: "exact", head: true })
      .eq("is_deleted", false),
    adminClient.from("api_usage_logs")
      .select("created_at")
      .gte("created_at", yesterday24h)
      .order("created_at", { ascending: true }),
  ]);

  // Aggregate hourly counts in-process (0-23)
  const callsByHour: { hour: number; count: number }[] = Array.from({ length: 24 }, (_, h) => ({ hour: h, count: 0 }));
  for (const row of (hourlyRows ?? [])) {
    const h = new Date(row.created_at).getHours();
    callsByHour[h].count++;
  }

  const stats = {
    total_users: total_users ?? 0,
    active_today: active_today ?? 0,
    flagged_users: flagged_users ?? 0,
    banned_users: banned_users ?? 0,
    api_calls_24h: api_calls_24h ?? 0,
    total_vocabularies: total_vocabularies ?? 0,
    calls_by_hour: callsByHour,
  };

  return new Response(JSON.stringify(stats), {
    status: 200,
    headers: { ...corsHeaders, "Content-Type": "application/json" },
  });
}

async function handleListUsers(adminClient: any): Promise<Response> {
  const sevenDaysAgo = new Date(Date.now() - 7 * 24 * 60 * 60 * 1000).toISOString();

  const { data: profiles, error } = await adminClient
    .from("profiles")
    .select("id, email, display_name, avatar_url, created_at, last_active_at, is_banned, is_flagged")
    .order("created_at", { ascending: false });

  if (error) throw error;

  // Get vocab counts and 7-day API call counts per user in batch
  const userIds = (profiles ?? []).map((p: any) => p.id);

  const [{ data: vocabCounts }, { data: callCounts }] = await Promise.all([
    adminClient
      .from("vocabularies")
      .select("user_id")
      .in("user_id", userIds)
      .eq("is_deleted", false),
    adminClient
      .from("api_usage_logs")
      .select("user_id")
      .in("user_id", userIds)
      .gte("created_at", sevenDaysAgo),
  ]);

  const vocabMap: Record<string, number> = {};
  for (const row of (vocabCounts ?? [])) {
    vocabMap[row.user_id] = (vocabMap[row.user_id] ?? 0) + 1;
  }
  const callMap: Record<string, number> = {};
  for (const row of (callCounts ?? [])) {
    callMap[row.user_id] = (callMap[row.user_id] ?? 0) + 1;
  }

  const users = (profiles ?? []).map((p: any) => ({
    id: p.id,
    email: p.email,
    display_name: p.display_name,
    avatar_url: p.avatar_url,
    created_at: p.created_at,
    last_active_at: p.last_active_at,
    is_banned: p.is_banned,
    is_flagged: p.is_flagged,
    vocab_count: vocabMap[p.id] ?? 0,
    api_calls_7d: callMap[p.id] ?? 0,
  }));

  return new Response(JSON.stringify(users), {
    status: 200,
    headers: { ...corsHeaders, "Content-Type": "application/json" },
  });
}

async function handleUserDetail(userId: string, adminClient: any): Promise<Response> {
  const sevenDaysAgo = new Date(Date.now() - 7 * 24 * 60 * 60 * 1000).toISOString();
  const yesterday24h = new Date(Date.now() - 24 * 60 * 60 * 1000).toISOString();

  const [
    { data: profile },
    { data: dailyRows },
    { data: hourlyRows },
    { data: recentLogs },
    { count: vocabCount },
    { count: totalCalls },
  ] = await Promise.all([
    adminClient
      .from("profiles")
      .select("id, email, display_name, avatar_url, created_at, last_active_at, is_banned, is_flagged, banned_at, ban_reason")
      .eq("id", userId)
      .single(),
    adminClient
      .from("api_usage_logs")
      .select("created_at")
      .eq("user_id", userId)
      .gte("created_at", sevenDaysAgo)
      .order("created_at", { ascending: true }),
    adminClient
      .from("api_usage_logs")
      .select("created_at")
      .eq("user_id", userId)
      .gte("created_at", yesterday24h)
      .order("created_at", { ascending: true }),
    adminClient
      .from("api_usage_logs")
      .select("id, action, word, status, created_at")
      .eq("user_id", userId)
      .order("created_at", { ascending: false })
      .limit(50),
    adminClient
      .from("vocabularies")
      .select("id", { count: "exact", head: true })
      .eq("user_id", userId)
      .eq("is_deleted", false),
    adminClient
      .from("api_usage_logs")
      .select("id", { count: "exact", head: true })
      .eq("user_id", userId),
  ]);

  // Aggregate daily calls (7 days)
  const dailyMap: Record<string, number> = {};
  for (const row of (dailyRows ?? [])) {
    const date = row.created_at.slice(0, 10);
    dailyMap[date] = (dailyMap[date] ?? 0) + 1;
  }
  const daily_calls = Object.entries(dailyMap).map(([date, count]) => ({ date, count }));

  // Aggregate hourly calls (24h)
  const hourlyArr: { hour: number; count: number }[] = Array.from({ length: 24 }, (_, h) => ({ hour: h, count: 0 }));
  for (const row of (hourlyRows ?? [])) {
    hourlyArr[new Date(row.created_at).getHours()].count++;
  }

  const todayStart = new Date();
  todayStart.setHours(0, 0, 0, 0);
  const callsToday = (hourlyRows ?? []).filter(
    (r: any) => new Date(r.created_at) >= todayStart
  ).length;

  const userDetail = {
    profile: {
      ...profile,
      vocab_count: vocabCount ?? 0,
      api_calls_today: callsToday,
      api_calls_7d: (dailyRows ?? []).length,
      api_calls_total: totalCalls ?? 0,
    },
    daily_calls,
    hourly_calls: hourlyArr,
    recent_logs: recentLogs ?? [],
  };

  return new Response(JSON.stringify(userDetail), {
    status: 200,
    headers: { ...corsHeaders, "Content-Type": "application/json" },
  });
}

async function handleBanUser(userId: string, reason: string, adminClient: any): Promise<Response> {
  if (!userId) {
    return new Response(JSON.stringify({ error: "user_id required" }), {
      status: 400,
      headers: { ...corsHeaders, "Content-Type": "application/json" },
    });
  }
  if (!reason || reason.trim().length < 10) {
    return new Response(JSON.stringify({ error: "Lý do ban phải có ít nhất 10 ký tự" }), {
      status: 400,
      headers: { ...corsHeaders, "Content-Type": "application/json" },
    });
  }

  const { error } = await adminClient
    .from("profiles")
    .update({
      is_banned: true,
      banned_at: new Date().toISOString(),
      ban_reason: reason.trim(),
      is_flagged: false,
    })
    .eq("id", userId);

  if (error) throw error;
  return new Response(JSON.stringify({ success: true }), {
    status: 200,
    headers: { ...corsHeaders, "Content-Type": "application/json" },
  });
}

async function handleUnbanUser(userId: string, adminClient: any): Promise<Response> {
  if (!userId) {
    return new Response(JSON.stringify({ error: "user_id required" }), {
      status: 400,
      headers: { ...corsHeaders, "Content-Type": "application/json" },
    });
  }
  const { error } = await adminClient
    .from("profiles")
    .update({ is_banned: false, banned_at: null, ban_reason: null })
    .eq("id", userId);

  if (error) throw error;
  return new Response(JSON.stringify({ success: true }), {
    status: 200,
    headers: { ...corsHeaders, "Content-Type": "application/json" },
  });
}

async function handleUnflagUser(userId: string, adminClient: any): Promise<Response> {
  if (!userId) {
    return new Response(JSON.stringify({ error: "user_id required" }), {
      status: 400,
      headers: { ...corsHeaders, "Content-Type": "application/json" },
    });
  }
  const { error } = await adminClient
    .from("profiles")
    .update({ is_flagged: false })
    .eq("id", userId);

  if (error) throw error;
  return new Response(JSON.stringify({ success: true }), {
    status: 200,
    headers: { ...corsHeaders, "Content-Type": "application/json" },
  });
}
