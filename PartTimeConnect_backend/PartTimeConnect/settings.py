from pathlib import Path
from decouple import config
import os

# print(config('DJANGO_SECRET_KEY'))  # Check if the secret key loads
# print(config('SENDGRID_API_KEY'))  # Check if the SendGrid API key loads

SECRET_KEY = config('DJANGO_SECRET_KEY')  # Fetch secret key from .env file
EMAIL_HOST_PASSWORD = config('SENDGRID_API_KEY')  # Fetch SendGrid API key from .env file

# Build paths inside the project like this: BASE_DIR / 'subdir'.
BASE_DIR = Path(__file__).resolve().parent.parent

# Quick-start development settings - unsuitable for production
DEBUG = True

MEDIA_URL = '/media/'
MEDIA_ROOT = os.path.join(BASE_DIR, 'media')

ALLOWED_HOSTS = [
    '127.0.0.1',
    'localhost',
    '10.0.2.2',
]

INSTALLED_APPS = ['daphne',
    'django.contrib.admin','django.contrib.auth','django.contrib.contenttypes','django.contrib.sessions','django.contrib.messages',
    'django.contrib.staticfiles','api','rest_framework','rest_framework.authtoken','corsheaders','accounts','jobs','feedback','chat',
    'collab','background_task','django_extensions'
]

MIDDLEWARE = [
    'corsheaders.middleware.CorsMiddleware','django.middleware.common.CommonMiddleware','django.middleware.security.SecurityMiddleware',
    'django.contrib.sessions.middleware.SessionMiddleware','django.middleware.csrf.CsrfViewMiddleware','django.contrib.auth.middleware.AuthenticationMiddleware',
    'django.contrib.messages.middleware.MessageMiddleware','django.middleware.clickjacking.XFrameOptionsMiddleware',
]

CORS_ALLOWED_ORIGINS = ['http://10.0.2.2:8000',]
CSRF_TRUSTED_ORIGINS = ['http://127.0.0.1:8000']
CSRF_COOKIE_NAME = 'csrftoken'
CSRF_COOKIE_HTTPONLY = False
CSRF_COOKIE_SECURE = False  # Set to True if using HTTPS
CSRF_USE_SESSIONS = False

ROOT_URLCONF = 'PartTimeConnect.urls'

TEMPLATES = [
    {
        'BACKEND': 'django.template.backends.django.DjangoTemplates',
        'DIRS': [],
        'APP_DIRS': True,
        'OPTIONS': {
            'context_processors': [
                'django.template.context_processors.debug',
                'django.template.context_processors.request',
                'django.contrib.auth.context_processors.auth',
                'django.contrib.messages.context_processors.messages',
            ],
        },
    },
]


WSGI_APPLICATION = 'PartTimeConnect.wsgi.application'

# Email backend setup for SendGrid
EMAIL_BACKEND = 'django.core.mail.backends.smtp.EmailBackend'
EMAIL_HOST = 'smtp.sendgrid.net'
EMAIL_PORT = 587
EMAIL_USE_TLS = True
EMAIL_USE_SSL = False
EMAIL_HOST_USER = 'apikey'  # Always 'apikey' for SendGrid
EMAIL_HOST_PASSWORD = EMAIL_HOST_PASSWORD  # Use environment variable for SendGrid API key
DEFAULT_FROM_EMAIL = 'mariem.benamor@ensi-uma.tn'  # Replace with your email address

DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.sqlite3',
        'NAME': BASE_DIR / 'db.sqlite3',
    }
}

AUTH_PASSWORD_VALIDATORS = [
    {
        'NAME': 'django.contrib.auth.password_validation.UserAttributeSimilarityValidator',
    },
    {
        'NAME': 'django.contrib.auth.password_validation.MinimumLengthValidator',
    },
    {
        'NAME': 'django.contrib.auth.password_validation.CommonPasswordValidator',
    },
    {
        'NAME': 'django.contrib.auth.password_validation.NumericPasswordValidator',
    },
]

LANGUAGE_CODE = 'en-us'
TIME_ZONE = 'UTC'
USE_I18N = True
USE_TZ = True

STATIC_URL = 'static/'

DEFAULT_AUTO_FIELD = 'django.db.models.BigAutoField'


REST_FRAMEWORK = {
    'DEFAULT_AUTHENTICATION_CLASSES': [
        'rest_framework.authentication.TokenAuthentication',
        'rest_framework.authentication.SessionAuthentication',  # Keep this if using CSRF
    ],
    # 'DEFAULT_PERMISSION_CLASSES': [
    #    'rest_framework.permissions.IsAuthenticated',
    # ]
}

# Pour indiquer qu'on utilise ASGI
ASGI_APPLICATION = 'PartTimeConnect.asgi.application'

# Configuration du Channel Layer avec Redis
CHANNEL_LAYERS = {
    "default": {
        "BACKEND": "channels_redis.core.RedisChannelLayer",
        "CONFIG": {
            "hosts": [("127.0.0.1", 6379)],
        },
    },
}
ALLOWED_HOSTS = ['*']



