import { createClient } from '@supabase/supabase-js'

const runtimeConfig = window.__APP_CONFIG__ || {}

const supabaseUrl =
  runtimeConfig.VITE_SUPABASE_URL || import.meta.env.VITE_SUPABASE_URL
const supabaseKey =
  runtimeConfig.VITE_SUPABASE_PUBLISHABLE_KEY ||
  runtimeConfig.VITE_SUPABASE_ANON_KEY ||
  import.meta.env.VITE_SUPABASE_PUBLISHABLE_KEY ||
  import.meta.env.VITE_SUPABASE_ANON_KEY

if (!supabaseUrl || !supabaseKey) {
  throw new Error(
    'Missing Supabase environment variables. Define VITE_SUPABASE_URL and VITE_SUPABASE_PUBLISHABLE_KEY or VITE_SUPABASE_ANON_KEY.',
  )
}

export const supabase = createClient(supabaseUrl, supabaseKey)
