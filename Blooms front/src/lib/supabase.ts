import { createClient } from '@supabase/supabase-js';

const supabaseUrl =
  process.env.NEXT_PUBLIC_SUPABASE_URL || 'https://opzarhigxksuaabtbwym.supabase.co';
const supabaseServiceKey =
  process.env.SUPABASE_SERVICE_ROLE_KEY ||
  'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im9wemFyaGlneGtzdWFhYnRid3ltIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc5MTM2Mzc4MiwiZXhwIjoyMTA2OTM5NzgyfQ.fmTt5wgtNphsHhL3a4myNkU40VNBeZoTsGkVz7GPa3o';

export const supabaseAdmin = createClient(supabaseUrl, supabaseServiceKey, {
  auth: {
    persistSession: false,
    autoRefreshToken: false,
  },
});
