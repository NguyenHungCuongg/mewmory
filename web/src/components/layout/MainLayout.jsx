import { Outlet } from "react-router-dom";
import Sidebar from "./Sidebar";

export default function MainLayout() {
  return (
    <div className="flex min-h-screen bg-eggshell">
      <Sidebar />
      <main className="flex-1 ml-60 overflow-auto">
        <Outlet />
      </main>
    </div>
  );
}
