"""Override Settings env_file before any app code runs."""
import os

# Set all required env vars so Settings() succeeds with defaults.
os.environ.update({
    "APP_ENV": "test",
    "OPENAI_API_KEY": "",
    "FIREBASE_PROJECT_ID": "test-project",
    "FIREBASE_CREDENTIALS_PATH": "",
    "FIREBASE_CREDENTIALS_JSON": "",
    "FIREBASE_STORAGE_BUCKET": "test.appspot.com",
    "API_CORS_ORIGINS": "http://localhost:3000",
})

# Monkey-patch Settings to not read .env so we use env vars above.
from pydantic_settings import SettingsConfigDict
import app.core.config as _cfg

_cfg.Settings.model_config = SettingsConfigDict(env_file=None)
_cfg.get_settings.cache_clear()
