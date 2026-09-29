-- D6 (dev-docs/BUG_AUDIT_2026-09-28.md): updated_at was only server-set on UPDATE.
-- On INSERT it kept the client's clock, so a device with a skewed clock wrote
-- timestamps that break the incremental-sync cursor on other devices.
-- Reuse update_updated_at() (00002) so every write gets the server's NOW().
CREATE TRIGGER vocabularies_updated_at_on_insert
    BEFORE INSERT ON public.vocabularies
    FOR EACH ROW EXECUTE FUNCTION public.update_updated_at();

CREATE TRIGGER definitions_updated_at_on_insert
    BEFORE INSERT ON public.definitions
    FOR EACH ROW EXECUTE FUNCTION public.update_updated_at();

CREATE TRIGGER collections_updated_at_on_insert
    BEFORE INSERT ON public.collections
    FOR EACH ROW EXECUTE FUNCTION public.update_updated_at();

CREATE TRIGGER vocab_collections_updated_at_on_insert
    BEFORE INSERT ON public.vocabulary_collections
    FOR EACH ROW EXECUTE FUNCTION public.update_updated_at();

CREATE TRIGGER user_settings_updated_at_on_insert
    BEFORE INSERT ON public.user_settings
    FOR EACH ROW EXECUTE FUNCTION public.update_updated_at();
