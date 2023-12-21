# Project Makefile
#
# A generic makefile for projects.
#
# https://github.com/project-makefile/project-makefile
 
# License
#
# Copyright 2016—2023 Jeffrey A. Clark (Alex)
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

# --------------------------------------------------------------------------------
# Variables
# --------------------------------------------------------------------------------

GIT_BRANCHES = `git branch -a \
	| grep remote  \
	| grep -v HEAD \
	| grep -v main \
	| grep -v master`

UNAME := $(shell uname)
RANDIR := $(shell openssl rand -base64 12 | sed 's/\///g')
TMPDIR := $(shell mktemp -d)

define INTERNAL_IPS
INTERNAL_IPS = ["127.0.0.1",]
endef

define CONTEXT_INDEX
export { UserContextProvider as default } from './UserContextProvider';
endef

define CONTEXT_USER_PROVIDER
// UserContextProvider.js
import React, { createContext, useContext, useState } from 'react';
import PropTypes from 'prop-types';

const UserContext = createContext();

export const UserContextProvider = ({ children }) => {
  const [isAuthenticated, setIsAuthenticated] = useState(false);

  const login = () => {
    try {
      // Add logic to handle login, set isAuthenticated to true
      setIsAuthenticated(true);
    } catch (error) {
      console.error('Login error:', error);
      // Handle error, e.g., show an error message to the user
    }
  };

  const logout = () => {
    try {
      // Add logic to handle logout, set isAuthenticated to false
      setIsAuthenticated(false);
    } catch (error) {
      console.error('Logout error:', error);
      // Handle error, e.g., show an error message to the user
    }
  };

  return (
    <UserContext.Provider value={{ isAuthenticated, login, logout }}>
      {children}
    </UserContext.Provider>
  );
};

UserContextProvider.propTypes = {
  children: PropTypes.node.isRequired,
};

export const useUserContext = () => {
  const context = useContext(UserContext);

  if (!context) {
    throw new Error('useUserContext must be used within a UserContextProvider');
  }

  return context;
};

// Add PropTypes for the return value of useUserContext
useUserContext.propTypes = {
  isAuthenticated: PropTypes.bool.isRequired,
  login: PropTypes.func.isRequired,
  logout: PropTypes.func.isRequired,
};
endef


define COMPONENT_USER_MENU
// UserMenu.js
import React from 'react';
import PropTypes from 'prop-types';

function handleLogout() {
    window.location.href = '/accounts/logout';
}

const UserMenu = ({ isAuthenticated }) => {
  return (
    <div>
      {isAuthenticated ? (
        <div className="dropdown">
          <button className="btn dropdown-toggle" type="button" data-bs-toggle="dropdown" aria-expanded="false">
            User Menu
          </button>
          <ul className="dropdown-menu">
            <li><a className="dropdown-item" href="/accounts/logout">Logout</a></li>
          </ul>
        </div>
      ) : (
        <a className="btn" href="/accounts/login">Login</a>
      )}
    </div>
  );
};

UserMenu.propTypes = {
  isAuthenticated: PropTypes.bool.isRequired,
};

export default UserMenu;
endef

define COMPONENT_CLOCK
// Via ChatGPT
import React, { useState, useEffect, useCallback, useRef } from 'react';
import PropTypes from 'prop-types';

const Clock = ({ color = '#fff' }) => {
  const [date, setDate] = useState(new Date());
  const [blink, setBlink] = useState(true);
  const timerID = useRef();

  const tick = useCallback(() => {
    setDate(new Date());
    setBlink(prevBlink => !prevBlink);
  }, []);

  useEffect(() => {
    timerID.current = setInterval(() => tick(), 1000);

    // Return a cleanup function to be run on component unmount
    return () => clearInterval(timerID.current);
  }, [tick]);

  const formattedDate = date.toLocaleDateString(undefined, {
    year: 'numeric',
    month: 'long',
    day: 'numeric',
  });

  const formattedTime = date.toLocaleTimeString(undefined, {
    hour: 'numeric',
    minute: 'numeric',
  });

  return (
    <span> 
      <span style={{ animation: blink ? 'blink 1s infinite' : 'none' }}>{formattedDate}</span>
      <div>{formattedTime}</div>
    </span>
  );
};

Clock.propTypes = {
  color: PropTypes.string,
};

export default Clock;
endef

define FRONTEND_APP
import React from 'react';
import { createRoot } from 'react-dom/client';
import "../styles/index.scss";
import "../styles/theme-blue.scss";
import getDataComponents from '../dataComponents';
import * as components from '../components';

// eslint-disable-next-line no-unused-vars
import bootstrap from 'bootstrap';

import UserContextProvider from '../context';

const { ErrorBoundary } = components;
const dataComponents = getDataComponents(components);
const container = document.getElementById('app');
const root = createRoot(container);
const App = () => (
    <ErrorBoundary>
      <UserContextProvider>
        {dataComponents}
      </UserContextProvider>
    </ErrorBoundary>
)
root.render(<App />);
endef

define BABELRC
{
  "presets": [
    [
      "@babel/preset-react",
    ],
    [
      "@babel/preset-env",
      {
        "useBuiltIns": "usage",
        "corejs": "3.0.0"
      }
    ]
  ],
  "plugins": [
    "@babel/plugin-syntax-dynamic-import",
    "@babel/plugin-transform-class-properties"
  ]
}
endef

define ESLINTRC
{
    "env": {
        "browser": true,
        "es2021": true,
        "node": true
    },
    "extends": [
        "eslint:recommended",
        "plugin:react/recommended"
    ],
    "overrides": [
        {
            "env": {
                "node": true
            },
            "files": [
                ".eslintrc.{js,cjs}"
            ],
            "parserOptions": {
                "sourceType": "script"
            }
        }
    ],
    "parserOptions": {
        "ecmaVersion": "latest",
        "sourceType": "module"
    },
    "plugins": [
        "react"
    ],
    "rules": {
        "no-unused-vars": "off"
    },
    settings: {
      react: {
        version: 'detect',
      },
    },
}
endef

define BASE_TEMPLATE
{% load static wagtailcore_tags wagtailuserbar webpack_loader %}

<!DOCTYPE html>
<html lang="en" data-bs-theme="blue">
    <head>
        <meta charset="utf-8" />
        <title>
            {% block title %}
            {% if page.seo_title %}{{ page.seo_title }}{% else %}{{ page.title }}{% endif %}
            {% endblock %}
            {% block title_suffix %}
            {% wagtail_site as current_site %}
            {% if current_site and current_site.site_name %}- {{ current_site.site_name }}{% endif %}
            {% endblock %}
        </title>
        {% if page.search_description %}
        <meta name="description" content="{{ page.search_description }}" />
        {% endif %}
        <meta name="viewport" content="width=device-width, initial-scale=1" />

        {# Force all links in the live preview panel to be opened in a new tab #}
        {% if request.in_preview_panel %}
        <base target="_blank">
        {% endif %}

  		{% stylesheet_pack 'app' %}

        {% block extra_css %}
        {# Override this in templates to add extra stylesheets #}
        {% endblock %}

		<link href="{% static 'wagtailadmin/images/favicon.ico' %}" rel="icon">
    </head>

    <body class="{% block body_class %}{% endblock %}">
        {% wagtailuserbar %}

		<div id="app"></div>

		{% include 'navbar.html' %}
        {% block content %}{% endblock %}
		{% include 'footer.html' %}

		{% javascript_pack 'app' %}

        {% block extra_js %}
        {# Override this in templates to add extra javascript #}
        {% endblock %}
    </body>
</html>
endef

define HOME_PAGE_MODEL
from django.db import models
from wagtail.models import Page
from wagtail.fields import RichTextField, StreamField
from wagtail import blocks
from wagtail.admin.panels import FieldPanel
from wagtail.images.blocks import ImageChooserBlock

class MarketingBlock(blocks.StructBlock):
    title = blocks.CharBlock(required=False, help_text='Enter the block title')
    content = blocks.RichTextBlock(required=False, help_text='Enter the block content')
    image = ImageChooserBlock(required=False, help_text='Select an optional image for the block')

    class Meta:
        icon = 'placeholder'
        template = 'blocks/marketing_block.html'  # Create a template for rendering the block

class HomePage(Page):
    template = 'home/home_page.html'  # Create a template for rendering the home page

    # Fields for the home page
    body = RichTextField(blank=True, help_text='Main content of the page', null=True)
    marketing_blocks = StreamField([
        ('marketing_block', MarketingBlock()),
    ], blank=True, null=True, use_json_field=True)

    content_panels = Page.content_panels + [
        FieldPanel('body'),
        FieldPanel('marketing_blocks'),
    ]

    class Meta:
        verbose_name = 'Home Page'
endef

define ALLAUTH_LAYOUT_BASE
{% extends 'base.html' %}
endef

define MARKETING_BLOCK_TEMPLATE
{% load wagtailcore_tags %}

<div class="bg-body-tertiary vh-100">
    {% if self.title %}
        <h2>{{ self.title }}</h2>
    {% endif %}

    {% if self.image %}
        <img src="{{ self.image.url }}" alt="{{ self.title }}">
    {% endif %}

    {% if self.content %}
        <div class="content">
            {{ self.content|richtext }}
        </div>
    {% endif %}
</div>
endef


define HOME_PAGE_TEMPLATE
{% extends "base.html" %}
{% load wagtailcore_tags %}
{% block extra_css %}
    <style>
      .success {
          background-color: #d4edda;
          border-color: #c3e6cb;
          color: #155724;
      }
      .info {
          background-color: #d1ecf1;
          border-color: #bee5eb;
          color: #0c5460;
      }
      .warning {
          background-color: #fff3cd;
          border-color: #ffeeba;
          color: #856404;
      }
      .danger {
          background-color: #f8d7da;
          border-color: #f5c6cb;
          color: #721c24;
      }
    </style>
{% endblock %}
{% block content %}
    <main class="{% block main_class %}{% endblock %}">
        {% if messages %}
            <div class="messages">
                {% for message in messages %}
                    <div class="alert {{ message.tags }} alert-dismissible fade show"
                         role="alert">
                        {{ message }}
                        <button type="button"
                                class="btn-close"
                                data-bs-dismiss="alert"
                                aria-label="Close"></button>
                    </div>
                {% endfor %}
            </div>
        {% endif %}
        <div class="lead mt-5">{{ page.body|default:''|safe }}</div>
		{% for block in page.marketing_blocks %}
		  {% include_block block %}
		{% endfor %}
    </main>
{% endblock %}
endef

define JENKINS_FILE
pipeline {
    agent any
    stages {
        stage('') {
            steps {
                echo ''
            }
        }
	}
}
endef

define AUTHENTICATION_BACKENDS
AUTHENTICATION_BACKENDS = [
    'django.contrib.auth.backends.ModelBackend',
    'allauth.account.auth_backends.AuthenticationBackend',
]
endef

define URL_PATTERNS
from django.conf import settings
from django.urls import include, path
from django.contrib import admin

from wagtail.admin import urls as wagtailadmin_urls
from wagtail import urls as wagtail_urls
from wagtail.documents import urls as wagtaildocs_urls

from search import views as search_views

from django.contrib.auth.models import User
from rest_framework import routers, serializers, viewsets
from dj_rest_auth.registration.views import RegisterView

urlpatterns = [
	path('accounts/', include('allauth.urls')),
    path('django/', admin.site.urls),
    path('wagtail/', include(wagtailadmin_urls)),
]

if settings.DEBUG:
    from django.conf.urls.static import static
    from django.contrib.staticfiles.urls import staticfiles_urlpatterns

    # Serve static and media files from development server
    urlpatterns += staticfiles_urlpatterns()
    urlpatterns += static(settings.MEDIA_URL, document_root=settings.MEDIA_ROOT)

    import debug_toolbar
    urlpatterns += [
        path("__debug__/", include(debug_toolbar.urls)),
    	path("hijack/", include("hijack.urls")),
    ]

# https://www.django-rest-framework.org/#example
class UserSerializer(serializers.HyperlinkedModelSerializer):
    class Meta:
        model = User
        fields = ['url', 'username', 'email', 'is_staff']

class UserViewSet(viewsets.ModelViewSet):
    queryset = User.objects.all()
    serializer_class = UserSerializer

router = routers.DefaultRouter()
router.register(r'users', UserViewSet)

urlpatterns += [
    path("api/", include(router.urls)),
    path("api/", include("rest_framework.urls", namespace="rest_framework")),
	path("api/", include("dj_rest_auth.urls")),
    path("api/register/", RegisterView.as_view(), name="register"),
]

urlpatterns += [
    # For anything not caught by a more specific rule above, hand over to
    # Wagtail's page serving mechanism. This should be the last pattern in
    # the list:
    path("", include(wagtail_urls)),

    # Alternatively, if you want Wagtail pages to be served from a subpath
    # of your site, rather than the site root:
    #    path("pages/", include(wagtail_urls)),
]
endef

define REST_FRAMEWORK
REST_FRAMEWORK = {
    # Use Django's standard `django.contrib.auth` permissions,
    # or allow read-only access for unauthenticated users.
    'DEFAULT_PERMISSION_CLASSES': [
        'rest_framework.permissions.DjangoModelPermissionsOrAnonReadOnly'
    ]
}
endef

define GIT_IGNORE
bin/
__pycache__
lib/
lib64
pyvenv.cfg
node_modules/
share/
media/
endef

define WEBPACK_CONFIG_JS
const path = require('path');

module.exports = {
  mode: 'development',
  entry: './src/index.js',
  output: {
    filename: 'bundle.js',
    path: path.resolve(__dirname, 'dist'),
  },
};
endef

define WEBPACK_INDEX_JS
const message = "Hello, World!";
console.log(message);
endef

define WEBPACK_INDEX_HTML
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Hello, Webpack!</title>
</head>
<body>
  <script src="dist/bundle.js"></script>
</body>
</html>
endef

define REACT_PORTAL
// Via pwellever
import React from 'react';
import { createPortal } from 'react-dom';

const parseProps = data => Object.entries(data).reduce((result, [key, value]) => {
  if (value.toLowerCase() === 'true') {
    value = true;
  } else if (value.toLowerCase() === 'false') {
    value = false;
  } else if (value.toLowerCase() === 'null') {
    value = null;
  } else if (!isNaN(parseFloat(value)) && isFinite(value)) {
    // Parse numeric value
    value = parseFloat(value);
  } else if (
    (value[0] === '[' && value.slice(-1) === ']') || (value[0] === '{' && value.slice(-1) === '}')
  ) {
    // Parse JSON strings
    value = JSON.parse(value);
  }

  result[key] = value;
  return result;
}, {});

// This method of using portals instead of calling ReactDOM.render on individual components
// ensures that all components are mounted under a single React tree, and are therefore able
// to share context.

export default function getPageComponents (components) {
  const getPortalComponent = domEl => {
    // The element's "data-component" attribute is used to determine which component to render.
    // All other "data-*" attributes are passed as props.
    const { component: componentName, ...rest } = domEl.dataset;
    const Component = components[componentName];
    if (!Component) {
      console.error(`Component "$${componentName}" not found.`);
      return null;
    }
    const props = parseProps(rest);
    domEl.innerHTML = '';

    // eslint-disable-next-line no-unused-vars
    const { ErrorBoundary } = components;
    return createPortal(
      <ErrorBoundary>
        <Component {...props} />
      </ErrorBoundary>,
      domEl,
    );
  };

  return Array.from(document.querySelectorAll('[data-component]')).map(getPortalComponent);
}
endef

define FRONTEND_COMPONENTS
export { default as Clock } from './Clock';
export { default as ErrorBoundary } from './ErrorBoundary';
export { default as UserMenu } from './UserMenu';
endef

define FOOTER_HTML
  <footer class="my-5 pt-5 text-center text-small">
    <p class="mb-1">&copy; 2017–2023 Company Name</p>
    <ul class="list-inline">
      <li class="list-inline-item"><a class="text-secondary text-decoration-none" href="/privacy">Privacy</a></li>
      <li class="list-inline-item"><a class="text-secondary text-decoration-none" href="/terms-of-use">Terms</a></li>
      <li class="list-inline-item"><a class="text-secondary text-decoration-none" href="/support">Support</a></li>
    </ul>
    <div data-component="Clock"></div>
  </footer>
endef

define NAVBAR_HTML
		{% load wagtailcore_tags %}
        {% wagtail_site as current_site %}
		{% block extra_css %}
        <style>
          body {
            min-height: 75rem;
            padding-top: 4.5rem;
          } 
        </style>
		{% endblock %}
        <nav class="navbar navbar-expand-md fixed-top">
          <div class="container-fluid">
            <a class="navbar-brand" href="/">Project Makefile</a>
            <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#navbarCollapse" aria-controls="navbarCollapse" aria-expanded="false" aria-label="Toggle navigation">
              <span class="navbar-toggler-icon"></span>
            </button>
            <div class="collapse navbar-collapse" id="navbarCollapse">
              <ul class="navbar-nav me-auto mb-2 mb-md-0">
                <li class="nav-item">
                  <a class="nav-link active" aria-current="page" href="/">Home</a>
                </li>
                {% for child in current_site.root_page.get_children %}
                <li class="nav-item">
                  <a class="nav-link active" aria-current="page" href="{{ child.url }}">{{ child }}</a>
                </li>
                {% endfor %}
              </ul>
              <div data-component="UserMenu" data-is-authenticated="{{ request.user.is_authenticated }}"></div>
            </div>
          </div>
        </nav>
endef 

define COMPONENT_ERROR
import { Component } from 'react';
import PropTypes from 'prop-types';

class ErrorBoundary extends Component {
  constructor (props) {
    super(props);
    this.state = { hasError: false };
  }

  static getDerivedStateFromError () {
    return { hasError: true };
  }

  componentDidCatch (error, info) {
    const { onError } = this.props;
    console.error(error);
    onError && onError(error, info);
  }

  render () {
    const { children = null } = this.props;
    const { hasError } = this.state;

    return hasError ? null : children;
  }
}

ErrorBoundary.propTypes = {
  onError: PropTypes.func,
  children: PropTypes.node,
};

export default ErrorBoundary;
endef

define THEME_BLUE
@import "~bootstrap/scss/bootstrap.scss";

[data-bs-theme="blue"] {
  --bs-body-color: var(--bs-white);
  --bs-body-color-rgb: #{to-rgb($$white)};
  --bs-body-bg: var(--bs-blue);
  --bs-body-bg-rgb: #{to-rgb($$blue)};
  --bs-tertiary-bg: #{$$blue-600};

  .dropdown-menu {
    --bs-dropdown-bg: #{color-mix($$blue-500, $$blue-600)};
    --bs-dropdown-link-active-bg: #{$$blue-700};
  }

  .btn-secondary {
    --bs-btn-bg: #{color-mix($gray-600, $blue-400, .5)};
    --bs-btn-border-color: #{rgba($$white, .25)};
    --bs-btn-hover-bg: #{color-adjust(color-mix($gray-600, $blue-400, .5), 5%)};
    --bs-btn-hover-border-color: #{rgba($$white, .25)};
    --bs-btn-active-bg: #{color-adjust(color-mix($gray-600, $blue-400, .5), 10%)};
    --bs-btn-active-border-color: #{rgba($$white, .5)};
    --bs-btn-focus-border-color: #{rgba($$white, .5)};

    // --bs-btn-focus-box-shadow: 0 0 0 .25rem rgba(255, 255, 255, 20%);
  }
}
endef

export ALLAUTH_LAYOUT_BASE
export AUTHENTICATION_BACKENDS
export BABELRC
export BASE_TEMPLATE
export COMPONENT_CLOCK
export COMPONENT_ERROR
export COMPONENT_USER_MENU
export CONTEXT_INDEX
export CONTEXT_PROCESSOR
export CONTEXT_USER_PROVIDER
export ESLINTRC
export FOOTER_HTML
export FRONTEND_APP
export FRONTEND_COMPONENTS
export GIT_IGNORE
export HOME_PAGE_MODEL
export HOME_PAGE_TEMPLATE
export INTERNAL_IPS
export JENKINS_FILE
export MARKETING_BLOCK_TEMPLATE
export NAVBAR_HTML
export REACT_PORTAL
export REST_FRAMEWORK
export THEME_BLUE
export URL_PATTERNS
export WEBPACK_CONFIG_JS
export WEBPACK_INDEX_JS
export WEBPACK_INDEX_HTML

# ------------------------------------------------------------------------------  
# Rules
# ------------------------------------------------------------------------------  

# Elastic Beanstalk

eb-check-env-default:  # https://stackoverflow.com/a/4731504/185820
ifndef ENV_NAME
	$(error ENV_NAME is undefined)
endif
ifndef INSTANCE_TYPE
	$(error INSTANCE_TYPE is undefined)
endif
ifndef LB_TYPE
	$(error LB_TYPE is undefined)
endif
ifndef SSH_KEY
	$(error SSH_KEY is undefined)
endif
ifndef VPC_ID
	$(error VPC_ID is undefined)
endif
ifndef VPC_SG
	$(error VPC_SG is undefined)
endif
ifndef VPC_SUBNET_EC2
	$(error VPC_SUBNET_EC2 is undefined)
endif
ifndef VPC_SUBNET_ELB
	$(error VPC_SUBNET_ELB is undefined)
endif

eb-create-default: eb-check-env
	eb create $(ENV_NAME) \
		-i $(INSTANCE_TYPE) \
		-k $(SSH_KEY) \
		-p $(PLATFORM) \
		--elb-type $(LB_TYPE) \
		--vpc \
		--vpc.id $(VPC_ID) \
		--vpc.elbpublic \
		--vpc.ec2subnets $(VPC_SUBNET_EC2) \
		--vpc.elbsubnets $(VPC_SUBNET_ELB) \
		--vpc.publicip \
		--vpc.securitygroups $(VPC_SG)

eb-deploy-default:
	eb deploy

eb-init-default:
	eb init

# npm

npm-init-default:
	npm init -y
	-git add package.json

npm-install-default:
	npm install
	-git add package-lock.json

npm-clean-default:
	rm -rvf node_modules/
	rm -vf package-lock.json
	rm -rvf dist/

npm-start-default:
	npm run start

# Django

django-graph-default:
	python manage.py graph_models -a -o $(PROJECT_NAME).png

django-show-urls-default:
	python manage.py show_urls

django-loaddata-default:
	python manage.py loaddata

django-migrate-default:
	python manage.py migrate

django-migrations-default:
	python manage.py makemigrations

django-serve-default:
	cd frontend; npm run watch &
	python manage.py runserver 0.0.0.0:8000

django-settings-default:
	echo "# $(PROJECT_NAME)" >> $(SETTINGS)
	echo "ALLOWED_HOSTS = ['*']" >> $(SETTINGS)
	echo "import dj_database_url, os" >> $(SETTINGS)
	echo "DATABASE_URL = os.environ.get('DATABASE_URL', \
		'postgres://$(DB_USER):$(DB_PASS)@$(DB_HOST):$(DB_PORT)/$(PROJECT_NAME)')" >> $(SETTINGS)
	echo "DATABASES['default'] = dj_database_url.parse(DATABASE_URL)" >> $(SETTINGS)
	echo "INSTALLED_APPS.append('webpack_boilerplate')" >> $(SETTINGS)
	echo "INSTALLED_APPS.append('rest_framework')" >> $(SETTINGS)
	echo "INSTALLED_APPS.append('rest_framework.authtoken')" >> $(SETTINGS)
	echo "INSTALLED_APPS.append('allauth')" >> $(SETTINGS)
	echo "INSTALLED_APPS.append('allauth.account')" >> $(SETTINGS)
	echo "INSTALLED_APPS.append('allauth.socialaccount')" >> $(SETTINGS)
	echo "INSTALLED_APPS.append('wagtailmenus')" >> $(SETTINGS)
	echo "INSTALLED_APPS.append('wagtail_modeladmin')" >> $(SETTINGS)
	echo "INSTALLED_APPS.append('wagtailseo')" >> $(SETTINGS)
	echo "INSTALLED_APPS.append('wagtail.contrib.settings')" >> $(SETTINGS)
	echo "INSTALLED_APPS.append('django_extensions')" >> $(SETTINGS)
	echo "INSTALLED_APPS.append('debug_toolbar')" >> $(DEV_SETTINGS)
	echo "INSTALLED_APPS.append('crispy_forms')" >> $(SETTINGS)
	echo "INSTALLED_APPS.append('crispy_bootstrap5')" >> $(SETTINGS)
	echo "INSTALLED_APPS.append('django_recaptcha')" >> $(SETTINGS)
	echo "MIDDLEWARE.append('allauth.account.middleware.AccountMiddleware')" >> $(SETTINGS)
	echo "MIDDLEWARE.append('debug_toolbar.middleware.DebugToolbarMiddleware')" >> $(DEV_SETTINGS)
	echo "MIDDLEWARE.append('hijack.middleware.HijackUserMiddleware')" >> $(DEV_SETTINGS)
	echo "STATICFILES_DIRS.append(os.path.join(BASE_DIR, 'frontend/build'))" >> $(SETTINGS)
	echo "WEBPACK_LOADER = { 'MANIFEST_FILE': os.path.join(BASE_DIR, 'frontend/build/manifest.json'), }" >> $(SETTINGS)
	echo "$$REST_FRAMEWORK" >> $(SETTINGS)
	echo "$$INTERNAL_IPS" >> $(DEV_SETTINGS)
	echo "LOGIN_REDIRECT_URL = '/'" >> $(SETTINGS)
	echo "DEFAULT_AUTO_FIELD = 'django.db.models.BigAutoField'" >> $(SETTINGS)
	echo "$$AUTHENTICATION_BACKENDS" >> $(SETTINGS)
	echo "TEMPLATES[0]['OPTIONS']['context_processors'].append('wagtail.contrib.settings.context_processors.settings')" >> $(SETTINGS)
	echo "TEMPLATES[0]['OPTIONS']['context_processors'].append('wagtailmenus.context_processors.wagtailmenus')">> $(SETTINGS)
	echo "SILENCED_SYSTEM_CHECKS = ['django_recaptcha.recaptcha_test_key_error']" >> $(SETTINGS)

django-shell-default:
	python manage.py shell

django-static-default:
	python manage.py collectstatic --noinput

django-su-default:
	python manage.py shell -c "from django.contrib.auth.models import User; \
		User.objects.create_superuser('admin', '', 'admin')"

django-test-default:
	python manage.py test

django-user-default:
	python manage.py shell -c "from django.contrib.auth.models import User; \
		User.objects.create_user('user', '', 'user')"

django-url-patterns-default:
	echo "$$URL_PATTERNS" > backend/$(URLS)

django-npm-install-default:
	cd frontend; npm install

django-npm-install-save-default:
	cd frontend; npm install \
        @fortawesome/fontawesome-svg-core \
        @fortawesome/free-brands-svg-icons \
        @fortawesome/free-solid-svg-icons \
        @fortawesome/react-fontawesome \
        camelize \
        date-fns \
        history \
        mapbox-gl \
        query-string \
        react-animate-height \
        react-chartjs-2 \
        react-copy-to-clipboard \
        react-date-range \
        react-dom \
        react-dropzone \
        react-hook-form \
        react-image-crop \
        react-map-gl \
        react-modal \
        react-quill \
        react-resize-detector \
        react-select \
        react-swipeable \
        snakeize \
        striptags \
        url-join \
        viewport-mercator-project

django-npm-install-save-dev-default:
	cd frontend; npm install \
        eslint-plugin-react \
        eslint-config-standard \
        eslint-config-standard-jsx \
        @babel/core \
        @babel/preset-env \
        @babel/preset-react \
        --save-dev

django-npm-test-default:
	cd frontend; npm run test

django-npm-build-default:
	cd frontend; npm run build

django-open-default:
	open http://0.0.0.0:8000

# Git

git-ignore-default:
	echo "$$GIT_IGNORE" > .gitignore
	-git add .gitignore
	-git commit -a -m "Add .gitignore"
	-git push

git-branches-default:
	-for i in $(GIT_BRANCHES) ; do \
        git checkout -t $$i ; done

git-commit-default:
	-git commit -a -m $(GIT_MESSAGE)

git-push-default:
	-git push

git-commit-edit-default:
	-git commit -a

git-prune-default:
	git remote update origin --prune

git-set-upstream-default:
	git push --set-upstream origin main

git-commit-empty-default:
	git commit --allow-empty -m "Empty-Commit"

# Lint

lint-black-default:
	-black *.py
	-black backend/*.py
	-black backend/*/*.py
	-git commit -a -m "A one time black event"

lint-djlint-default:
	-djlint --reformat *.html
	-djlint --reformat backend/*.html
	-djlint --reformat backend/*/*.html
	-git commit -a -m "A one time djlint event"

lint-flake-default:
	-flake8 *.py
	-flake8 backend/*.py
	-flake8 backend/*/*.py

lint-isort-default:
	-isort *.py
	-isort backend/*.py
	-isort backend/*/*.py
	-git commit -a -m "A one time isort event"

lint-ruff-default:
	-ruff *.py
	-ruff backend/*.py
	-ruff backend/*/*.py
	-git commit -a -m "A one time ruff event"

# Database

mysql-init-default:
	-mysqladmin -u root drop $(PROJECT_NAME)
	-mysqladmin -u root create $(PROJECT_NAME)

pg-init-default:
	-dropdb $(PROJECT_NAME)
	-createdb $(PROJECT_NAME)


# pip

pip-freeze-default:
	pip3 freeze | sort > $(TMPDIR)/requirements.txt
	mv -f $(TMPDIR)/requirements.txt .
	-git add requirements.txt
	-git commit -a -m "Freezing requirements."

pip-install-default:
	$(MAKE) pip-upgrade
	pip3 install wheel
	pip3 install -r requirements.txt

pip-install-dev-default:
	pip3 install -r requirements-dev.txt

pip-install-test-default:
	pip3 install -r requirements-test.txt

pip-install-upgrade-default:
	cat requirements.txt | awk -F \= '{print $$1}' > $(TMPDIR)/requirements.txt
	mv -f $(TMPDIR)/requirements.txt .
	pip3 install -U -r requirements.txt
	pip3 freeze | sort > $(TMPDIR)/requirements.txt
	mv -f $(TMPDIR)/requirements.txt .

pip-upgrade-default:
	pip3 install -U pip

pip-init-default:
	touch requirements.txt
	-git add requirements.txt

# python

python-setup-sdist-default:
	python3 setup.py sdist --format=zip

# README

readme-init-default:
	@echo "$(PROJECT_NAME)" > README.rst
	@echo "================================================================================" >> README.rst
	-@git add README.rst
	-git commit -a -m "Add readme"

readme-edit-default:
	vi README.rst

readme-open-default:
	open README.pdf

readme-build-default:
	rst2pdf README.rst

# Sphinx

sphinx-init-default:
	$(MAKE) sphinx-install
	sphinx-quickstart -q -p $(PROJECT_NAME) -a $(USER) -v 0.0.1 $(RANDIR)
	mv $(RANDIR)/* .
	rmdir $(RANDIR)

sphinx-install-default:
	echo "Sphinx\n" > requirements.txt
	@$(MAKE) pip-install
	@$(MAKE) pip-freeze
	-git add requirements.txt

sphinx-build-default:
	sphinx-build -b html -d _build/doctrees . _build/html

sphinx-build-pdf-default:
	sphinx-build -b rinoh . _build/rinoh

sphinx-serve-default:
	cd _build/html;python -m http.server

# Wagtail

wagtail-clean-default:
	-rm -vf .dockerignore
	-rm -vf Dockerfile
	-rm -vf manage.py
	-rm -vf requirements.txt
	-rm -rvf home/
	-rm -rvf search/
	-rm -rvf backend/
	-rm -rvf frontend/
	-rm -vf README.rst

wagtail-init-default: db-init wagtail-install
	wagtail start backend .
	$(MAKE) pip-freeze
	export SETTINGS=backend/settings/base.py DEV_SETTINGS=backend/settings/dev.py; $(MAKE) django-settings
	export URLS=urls.py; $(MAKE) django-url-patterns
	-git add backend
	-git add requirements.txt
	-git add manage.py
	-git add Dockerfile
	-git add .dockerignore
	@echo "$$HOME_PAGE_MODEL" > home/models.py
	@$(MAKE) django-migrations
	-git add home
	-git add search
	@$(MAKE) django-migrate
	@$(MAKE) su
	@echo "$$BASE_TEMPLATE" > backend/templates/base.html
	@echo "$$NAVBAR_HTML" > backend/templates/navbar.html
	@echo "$$FOOTER_HTML" > backend/templates/footer.html
	mkdir -p backend/templates/allauth/layouts
	@echo "$$ALLAUTH_LAYOUT_BASE" > backend/templates/allauth/layouts/base.html
	-git add backend/templates/
	@echo "$$HOME_PAGE_TEMPLATE" > home/templates/home/home_page.html
	mkdir -p home/templates/blocks
	@echo "$$MARKETING_BLOCK_TEMPLATE" > home/templates/blocks/marketing_block.html
	-git add home/templates/blocks
	python manage.py webpack_init --no-input
	@echo "$$COMPONENT_CLOCK" > frontend/src/components/Clock.js
	@echo "$$COMPONENT_ERROR" > frontend/src/components/ErrorBoundary.js
	mkdir frontend/src/context
	@echo "$$CONTEXT_INDEX" > frontend/src/context/index.js
	@echo "$$CONTEXT_USER_PROVIDER" > frontend/src/context/UserContextProvider.js
	@echo "$$COMPONENT_USER_MENU" > frontend/src/components/UserMenu.js
	@echo "$$FRONTEND_APP" > frontend/src/application/app.js
	@echo "$$FRONTEND_COMPONENTS" > frontend/src/components/index.js
	@echo "$$REACT_PORTAL" > frontend/src/dataComponents.js
	@echo "$$BABELRC" > frontend/.babelrc
	@echo "$$ESLINTRC" > frontend/.eslintrc
	@echo "$$THEME_BLUE" > frontend/src/styles/theme-blue.scss
	-git add home
	-git add frontend
	-git commit -a -m "Add frontend"
	@$(MAKE) django-npm-install
	@$(MAKE) django-npm-install-save
	@$(MAKE) django-npm-install-save-dev
	@$(MAKE) cp
	@$(MAKE) lint-isort
	@$(MAKE) lint-black
	@$(MAKE) cp
	@$(MAKE) lint-flake
	@$(MAKE) readme
	@$(MAKE) gitignore
	@$(MAKE) serve

wagtail-install-default:
	pip3 install \
        crispy-bootstrap5 \
        djangorestframework \
        django-allauth \
        django-after-response \
        django-ckeditor \
        django-countries \
        django-crispy-forms \
        django-debug-toolbar \
        django-extensions \
        django-hijack \
        django-honeypot \
        django-imagekit \
        django-import-export \
        django-ipware \
        django-recurrence \
        django-recaptcha \
        django-registration \
        django-rest-auth \
        django-richtextfield \
        django-social-share \
        django-tables2 \
        django-timezone-field \
        dj-database-url \
        dj-stripe \
        dj-rest-auth \
        mailchimp-marketing \
        mailchimp-transactional \
        psycopg2-binary \
        python-webpack-boilerplate \
        wagtail \
        wagtailmenus \
        wagtail_modeladmin \
        wagtail-seo 

# Misc

help-default:
	@for makefile in $(MAKEFILE_LIST); do \
        $(MAKE) -pRrq -f $$makefile : 2>/dev/null \
            | awk -v RS= -F: '/^# File/,/^# Finished Make data base/ {if ($$1 !~ "^[#.]") {print $$1}}' \
            | sort | egrep -v -e '^[^[:alnum:]]' -e '^$@$$' \
            | xargs | tr ' ' '\n' \
            | awk '{printf "%s\n", $$0}' ; done | less # http://stackoverflow.com/a/26339924 Given a base.mk, Makefile and project.mk, and base.mk and project.mk included from Makefile, print target names from all makefiles.

usage-default:
	@echo "Project Makefile 🤷"
	@echo "Usage: make [options] [target] ..."
	@echo "Examples:"
	@echo "   make help    Print all targets"
	@echo "   make usage   Print this message"

jenkins-init-default:
	@echo "$$JENKINS_FILE" > Jenkinsfile

webpack-init-default: npm-init
	@echo "$$WEBPACK_CONFIG_JS" > webpack.config.js
	-git add webpack.config.js
	npm install --save-dev webpack webpack-cli
	-mkdir -v src/
	@echo "$$WEBPACK_INDEX_JS" > src/index.js
	-git add src/index.js
	@echo "$$WEBPACK_INDEX_HTML" > index.html
	-git add index.html

make-default:
	-git add base.mk
	-git add Makefile
	-git commit -a -m "Add/update project-makefile files"
	-git push

python-serve-default:
	@echo "\n\tServing HTTP on http://0.0.0.0:8000\n"
	python -m http.server

rand-default:
	@openssl rand -base64 12 | sed 's/\///g'

review-default:
ifeq ($(UNAME), Darwin)
	@open -a $(REVIEW_EDITOR) `find backend -name \*.py | grep -v migrations` `find backend -name \*.html` `find $(PROJECT_NAME) -name \*.js`
else
	@echo "Unsupported"
endif

project-mk-default:
	touch project.mk
	-git add project.mk

build-default: sphinx-build
b-default: build 
c-default: clean
ce-default: git-commit-edit-push
clean-default: wagtail-clean
cp-default: git-commit-push
d-default: eb-deploy
db-init-default: pg-init
django-clean-default: wagtail-clean
django-init-default: wagtail-init
edit-default: readme-edit
e-default: edit
empty-default: git-commit-empty
freeze-default: pip-freeze
h-default: help
init-default: wagtail-init
install-default: pip-install
install-dev-default: pip-install-dev
i-default: install
migrate-default: django-migrate
migrations-default: django-migrations
mk-default: project-mk
git-commit-edit-push-default: git-commit-edit git-push
git-commit-push-default: git-commit git-push
gitignore-default: git-ignore
open-default: django-open
o-default: open
p-default: git-push
readme-default: readme-init
serve-default: django-serve
shell-default: django-shell
su-default: django-su
s-default: serve
sdist-default: python-setup-sdist
u-default: usage
urls-default: django-show-urls
webpack-default: webpack-init

# Overrides

%: %-default  # https://stackoverflow.com/a/49804748
	@ true
