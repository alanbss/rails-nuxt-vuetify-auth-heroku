## About 
Placeholder Rails/Nuxt auth app 

Stack: Rails API backend with devise-jwt auth, Nuxt with Vuetify frontend
Sources:
- https://github.com/fishpercolator/autheg (super helpful, but out of date now)
- https://github.com/DakotaLMartinez/rails-devise-jwt-tutorial
- https://www.reddit.com/r/Nuxt/comments/js887t/comment/gbxprxa/?utm_source=share&utm_medium=web2x&context=3

## To Run/Deploy

### Install
- terminal tab #1:
  - `cd backend`
  - `bundle install`
  - `EDITOR='code --wait' rails credentials:edit` (just close this file once it opens)
  - `rails db:create db:migrate db:seed`
  - `rails s`
- terminal tab #2:
  - `cd frontend`
  - `yarn`
  - `yarn dev`

### Test App Locally
- in browser go to the `localhost:<port>` outputted in the `yarn dev` line above
  - log in as `test@mail.com`/`password` and go to `localhost:3000/private-contents`
  - you should see a list of "private content" items

### Deploy To Heroku
- `cd` into the `frontend` folder
- `yarn clean`
- `yarn build`
- `yarn copy`
- `cd` into app's main, top level folder
- `git add .`
- `git commit -m "init"`
- `heroku login` -> any key -> login on webpage
  - if `heroku login` gives you an `--openssl-legacy-provider is not allowed in NODE_OPTIONS` error, run `unset NODE_OPTIONS` and then run `heroku login` again
- `heroku create`
- in `frontend/nuxt.config.js` change the <heroku app name> in the last url in line 30 to the app name outputted in the above `heroku create` (ie, `thawing-headland-13757`)
- `yarn clean`
- `yarn build`
- `yarn copy`
- `cd` into the `backend` folder
- `bundle lock --add-platform x86_64-linux`
- `cd` into main app root folder
- `git add .`
- `git commit -m "updated heroku app name in nuxt.config.js axios setting"`
- `cd` into `backend` folder
- `heroku config`
- `EDITOR='code --wait' rails credentials:edit` -> copy secret keybase string
- `heroku config:set SECRET_KEYBASE=<secret keybase copied above>`
- copy master key from `backend/config/master.key`
- ``heroku config:set RAILS_MASTER_KEY=`cat config/master.key` --app '<heroku app name>'``
- `cd` into main app root folder
- `git subtree push --prefix backend heroku main`
- `heroku run rake db:migrate`
- `heroku run rake db:seed`
- `heroku ps:scale web=1`
- `heroku open`

## To Create

### Init App 
- `mkdir <app name>`
- `cd <app name>`
- `git init`
- `touch .gitignore`
- make `.gitignore` look like this:
```
backend/config/credentials.yml.enc

# Below are all the Nuxt default gitignore settings

# Logs
frontend/logs
frontend/*.log
frontend/npm-debug.log*
frontend/yarn-debug.log*
frontend/yarn-error.log*

# Runtime data
frontend/pids
frontend/*.pid
frontend/*.seed
frontend/*.pid.lock

# Directory for instrumented libs generated by jscoverage/JSCover
frontend/lib-cov

# Coverage directory used by tools like istanbul
frontend/coverage

# nyc test coverage
frontend/.nyc_output

# Grunt intermediate storage (http://gruntjs.com/creating-plugins#storing-task-files)
frontend/.grunt

# Bower dependency directory (https://bower.io/)
frontend/bower_components

# node-waf configuration
frontend/.lock-wscript

# Compiled binary addons (https://nodejs.org/api/addons.html)
frontend/build/Release

# Dependency directories
frontend/node_modules/
frontend/jspm_packages/

# TypeScript v1 declaration files
frontend/typings/

# Optional npm cache directory
frontend/.npm

# Optional eslint cache
frontend/.eslintcache

# Optional REPL history
frontend/.node_repl_history

# Output of 'npm pack'
frontend/*.tgz

# Yarn Integrity file
frontend/.yarn-integrity

# dotenv environment variables file
frontend/.env

# parcel-bundler cache (https://parceljs.org/)
frontend/.cache

# next.js build output
frontend/.next

# nuxt.js build output
frontend/.nuxt

# Nuxt generate
frontend/dist

# vuepress build output
frontend/.vuepress/dist

# Serverless directories
frontend/.serverless

# IDE / Editor
frontend/.idea

# Service worker
frontend/sw.*

# Vim swap files
frontend/*.swp

# macOS
.DS_Store
backend/.DS_Store
```
### Setup Backend
- `rails new backend --database=postgresql --skip-git`
- `cd backend`
- `bundle add rack-cors devise devise-jwt fast_jsonapi`
- `bundle install`
- `rails g scaffold PublicContent name:string`
- `rails g scaffold PrivateContent name:string`
- make `backend/db/seeds.rb` look like this:
```
PublicContent.create(name:'public content 1')
PublicContent.create(name:'public content 2')
PublicContent.create(name:'public content 3')
PrivateContent.create(name:'private content 1')
PrivateContent.create(name:'private content 2')
PrivateContent.create(name:'private content 3')
User.create(email:'test@mail.com',password:'password')
```
- `rails g task <app name> clean`
- make `backend/lib/tasks/<app name>.rake` look like this:
```
namespace :<app name> do
  
  desc "clean"
  task clean: :environment do
    sh "rm -rf public"
  end

end
```
- make `backend/config/routes.rb` look like this:
```
Rails.application.routes.draw do
  scope :api, defaults: {format: :json} do
    resources :public_contents, :private_contents
  end
end
```
- `rails g devise:install`
- `rails generate devise User`
- `rails g devise:controllers users -c sessions registrations`
- `rails g migration addJtiToUsers jti:string:index:unique`
- make the migration file `db/migrate/<date-time>_add_jti_to_to_users.rb` like this:
```
class AddJtiToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :jti, :string, null: false
    add_index :users, :jti, unique: true
  end
end
```
- make `backend/app/models/user.rb` look like this:
```
class User < ApplicationRecord
  include Devise::JWT::RevocationStrategies::JTIMatcher
  devise :database_authenticatable, :registerable, :validatable,
         :jwt_authenticatable, jwt_revocation_strategy: self
end
```
- `rails db:create db:migrate`
- make `backend/app/controllers/application_controller.rb` look like this:
```
class ApplicationController < ActionController::API
  include ActionController::MimeResponds
  respond_to :json
end
```
- make `backend/config/initializers/devise.rb` look like this:
```
Devise.setup do |config|
  config.mailer_sender = 'testapp@example.com'
  config.jwt do |jwt|
    # jwt.secret = Rails.application.credentials.fetch(:secret_key_base)
    jwt.secret = Rails.env.production? ? ENV["SECRET_KEY_BASE"] : Rails.application.credentials.fetch(:secret_key_base)
    # jwt.secret = ENV["SECRET_KEY_BASE"]
    jwt.dispatch_requests = [
      ['POST', %r{^/login$}]
    ]
    jwt.revocation_requests = [
      ['DELETE', %r{^/logout$}]
    ]
    jwt.expiration_time = 180.minutes.to_i
  end
  require 'devise/orm/active_record'
  config.case_insensitive_keys = [:email]
  config.strip_whitespace_keys = [:email]
  config.skip_session_storage = [:http_auth]
  config.stretches = Rails.env.test? ? 1 : 12
  config.reconfirmable = true
  config.expire_all_remember_me_on_sign_out = true
  config.password_length = 6..128
  config.reset_password_within = 6.hours
  config.sign_out_via = :delete
  config.navigational_formats = []
end
```
- if `backend/config/initializers/cors.rb` doesn't exist, do `touch backend/config/initializers/cors.rb`
- make `backend/config/initializers/cors.rb` look like this:
```
Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins "*"
    resource(
     '*',
     headers: :any,
     expose: ["Authorization"],
     methods: [:get, :patch, :put, :delete, :post, :options, :show]
    )
  end
end
```
- `rails db:migrate db:seed`
- `rails generate serializer user id email created_at`
- make `backend/app/controllers/users/sessions_controller.rb` look like this:
```
class Users::SessionsController < Devise::SessionsController
  respond_to :json
  private

  def respond_with(resource, _opts = {})
    render json: {
      status: {code: 200, message: 'Logged in sucessfully.'},
      data: UserSerializer.new(resource).serializable_hash[:data][:attributes]
    }, status: :ok
  end

  def respond_to_on_destroy
    if current_user
      render json: {
        status: 200,
        message: "logged out successfully"
      }, status: :ok
    else
      render json: {
        status: 401,
        message: "Couldn't find an active session."
      }, status: :unauthorized
    end
  end
end
```
- make `backend/app/controllers/users/registrations_controller.rb` look like this:
```
class Users::RegistrationsController < Devise::RegistrationsController
  respond_to :json
  private

  def respond_with(resource, _opts = {})
    if resource.persisted?
      render json: {
        status: {code: 200, message: 'Signed up sucessfully.'},
        data: UserSerializer.new(resource).serializable_hash[:data][:attributes]
      }
    else
      render json: {
        status: {message: "User couldn't be created successfully. #{resource.errors.full_messages.to_sentence}"}
      }, status: :unprocessable_entity
    end
  end
end
```
- `rails g controller current_user index`
- make `backend/app/controllers/current_user_controller.rb` look like this:
```
class CurrentUserController < ApplicationController
  before_action :authenticate_user!
  def index
    render json: current_user, status: :ok
  end
end
```
- make `backend/config/routes.rb` look like this:
```
Rails.application.routes.draw do  
  scope :api, defaults: {format: :json} do
    resources :private_contents, :public_contents
    get '/current_user', to: 'current_user#index'
    devise_for :users, path: '', path_names: {
      sign_in: 'login',
      sign_out: 'logout',
      registration: 'signup'
    },
    controllers: {
      sessions: 'users/sessions',
      registrations: 'users/registrations'
    }
  end
end
```
- make `backend/app/controllers/private_contents_controller.rb` look like this:
```
class PrivateContentsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_private_content, only: %i[ show update destroy ]

  # GET /private_contents
  def index
    @private_contents = PrivateContent.all

    render json: @private_contents
  end

  # GET /private_contents/1
  def show
    render json: @private_content
  end

  # POST /private_contents
  def create
    @private_content = PrivateContent.new(private_content_params)

    if @private_content.save
      render json: @private_content, status: :created, location: @private_content
    else
      render json: @private_content.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /private_contents/1
  def update
    if @private_content.update(private_content_params)
      render json: @private_content
    else
      render json: @private_content.errors, status: :unprocessable_entity
    end
  end

  # DELETE /private_contents/1
  def destroy
    @private_content.destroy
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_private_content
      @private_content = PrivateContent.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def private_content_params
      params.require(:private_content).permit(:name)
    end
end
```
- make `backend/config/application.rb` look like this:
```
require_relative "boot"
require "rails/all"
Bundler.require(*Rails.groups)

module Backend
  class Application < Rails::Application
    config.load_defaults 7.0
    config.session_store :cookie_store, key: '_interslice_session'
    config.middleware.use ActionDispatch::Cookies
    config.middleware.use config.session_store, config.session_options
  end
end
```
- `rails s`
- `curl http://localhost:3000/api/public_contents` should return:
```
[{"id":1,"name":"public content 1","created_at":"2022-08-16T23:06:21.560Z","updated_at":"2022-08-16T23:06:21.560Z","url":"http://localhost:3000/api/public_contents/1"},{"id":2,"name":"public content 2","created_at":"2022-08-16T23:06:21.568Z","updated_at":"2022-08-16T23:06:21.568Z","url":"http://localhost:3000/api/public_contents/2"},{"id":3,"name":"public content 3","created_at":"2022-08-16T23:06:21.573Z","updated_at":"2022-08-16T23:06:21.573Z","url":"http://localhost:3000/api/public_contents/3"}]
```
- `curl http://localhost:3000/api/private_contents` should return:
```
{"error":"You need to sign in or sign up before continuing."}
```
- `curl -X POST http://localhost:3000/api/login` should return:
```
{"error":"You need to sign in or sign up before continuing."}
```
- `curl -i http://localhost:3000/api/login -H 'Content-Type: application/json' -d '{"user": {"email": "test@mail.com", "password": "password"}}' | grep -zoE "(Authorization.*\n|{.*})"` should return something like:
```
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.eyJqdGkiOiJkYzEyZWUyYi1iMWI0LTQwZWMtYTAzYy00OWRhNjJjODdlNTUiLCJzdWIiOiIxIiwic2NwIjoidXNlciIsImF1ZCI6bnVsbCwiaWF0IjoxNjY4NjY1NTk0LCJleHAiOjE2Njg2NzYzOTR9.AzT2_LqwL9itXYBqUhin7QhNP6-ilb2FJy5ObK1vNRk

{"status":{"code":200,"message":"Logged in sucessfully."},"data":{"id":1,"email":"test@mail.com","created_at":"2022-11-17T05:10:13.479Z"}}
```
- `curl http://localhost:3000/api/current_user` should return 
```
{"error":"You need to sign in or sign up before continuing."}
```
- `curl http://localhost:3000/api/current_user -H "Authorization: Bearer <use token outputted above in login>" | grep -zoE "(.|\n)*"` should return something like:
```
{"id":1,"email":"test@mail.com","created_at":"2022-11-17T05:10:13.479Z","updated_at":"2022-11-17T05:10:13.479Z","jti":"dc12ee2b-b1b4-40ec-a03c-49da62c87e55"}
```

### Setup Frontend
 `cd` into the main `<app name>` folder 
- Run `npx create-nuxt-app frontend` and when prompted enter these for the questions 
  - Project name: hit enter to accept default of `frontend`
  - Programming language: Select `JavaScript` and hit enter
  - Package manager: Select `yarn` and hit enter 
  - UI framework: Select `Vuetify.js` and hit enter 
  - Templating engine: `HTML`
  - Nuxt.js modules: on `Axios` hit spacebar to select and then hit enter
  - Linting tools: press `enter` to contiue without choosing a linter 
  - Testing framework: `None`
  - Rendering Tools: select `Single Page App` and hit enter
  - Deployment target: select `Server` and hit enter 
  - Development tools: hit `enter` to continue without choosing any development tools 
  - Enter your `github username` and hit enter
  - Version control system: select `None` and hit enter
  - After that it will take a couple minutes for Nuxt to install the starter app files
- `cd frontend`
- `yarn`
- `yarn dev`
  - if this throws an error (`tried to access consola (a peer dependency) but it isn't provided`) copy/paste this whole block and press enter and then try `yarn` and then `yarn dev` again:
```
( rm .pnp.cjs
rm .pnp.loader.mjs
touch .yarnrc.yml
echo "nodeLinker: node-modules" > .yarnrc.yml )
```
  - if you get an `ERR_OSSL_EVP_UNSUPPORTED` error when you run `yarn dev`, just run this and then run `yarn dev` again:
```
export NODE_OPTIONS=--openssl-legacy-provider
```
- copy/paste this whole block into your terminal and press enter:
```
( sed -i '' 's/\"generate\": \"nuxt generate\"/\"generate\": \"nuxt generate\",\n\t\t\"clean\": \"rm -rf .\/..\/backend\/public\",\n\t\t\"copy\"\: \"mkdir ..\/backend\/public \&\& cp -r dist\/\* ..\/backend\/public\"/' package.json
touch store/index.js
touch pages/public-content.vue
touch pages/private-content.vue
touch pages/sign-up.vue
touch pages/log-in.vue 
yarn add --exact @nuxtjs/auth )
```

- make `frontend/nuxt.config.js` look like this:
```
import colors from 'vuetify/es5/util/colors'
const dev = process.env.NODE_ENV !== 'production'
export default {
  ssr: false,
  head: {
    titleTemplate: '%s - frontend',
    title: 'frontend',
    htmlAttrs: {
      lang: 'en'
    },
    meta: [
      { charset: 'utf-8' },
      { name: 'viewport', content: 'width=device-width, initial-scale=1' },
      { hid: 'description', name: 'description', content: '' },
      { name: 'format-detection', content: 'telephone=no' }
    ],
    link: [
      { rel: 'icon', type: 'image/x-icon', href: '/favicon.ico' }
    ]
  },
  components: true,
  buildModules: [
    '@nuxtjs/vuetify',
  ],
  modules: [
    '@nuxtjs/auth',
    '@nuxtjs/axios',
  ],
  axios: {
    baseURL: dev ? 'http://localhost:3000/api' : 'https://<heroku app name>.herokuapp.com/api',
  },
  auth: {
    strategies: {
      local: {
        endpoints: {
          registration:  { url: '/signup', propertyName: 'token' },
          login:  { url: '/login', propertyName: 'token' },
          logout: { url: '/logout', method: 'delete' },
          user:   { url: '/current_user', propertyName: false }
        },
        tokenName: 'Authorization',
        tokenType: ''
      }
    },
    redirect: {
      login: '/log-in',
      logout: '/',
      callback: '/log-in',
      home: '/'
    }
  },
  vuetify: {
    customVariables: ['~/assets/variables.scss'],
    theme: {
      dark: true,
      themes: {
        dark: {
          primary: colors.blue.darken2,
          accent: colors.grey.darken3,
          secondary: colors.amber.darken3,
          info: colors.teal.lighten1,
          warning: colors.amber.base,
          error: colors.deepOrange.accent4,
          success: colors.green.accent3
        }
      }
    }
  }
}
```
- make `frontend/layouts/default.vue` look like this:
```
<template>
  <div>
    <v-layout>
      <v-flex>
        <v-toolbar>
          <v-toolbar-title><NuxtLink to="/">Cool Guy Site 😎</NuxtLink></v-toolbar-title>
          <v-spacer />
          <NuxtLink to="/public-content">Public Content</NuxtLink>
          <NuxtLink to="/private-content">Private Content</NuxtLink>
          <NuxtLink v-if="!$auth.$state.loggedIn" to="/sign-up">Sign Up</NuxtLink>
          <NuxtLink v-if="!$auth.$state.loggedIn" to="/log-in">Log In</NuxtLink>
          <a href="#" v-if="$auth.$state.loggedIn" @click.prevent="logout">Log Out</a>
          <div class="logged-in-status">
            <span v-if="!$auth.$state.loggedIn">Not logged in</span>
            <span v-else>Logged in as {{this.$auth.user.email}}</span>
          </div>
        </v-toolbar>
        <v-main>
          <v-container>
            <v-row>
              <nuxt/>
            </v-row>
          </v-container>
        </v-main>
      </v-flex>
    </v-layout>
  </div>
</template>

<script>
export default {
  methods: {
    logout: function () {
      this.$auth.logout().catch(e => {this.error = e + ''})
    }
  }
}
</script>

<style>
html {
  font-family: "Source Sans Pro", -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, "Helvetica Neue", Arial, sans-serif;
  font-size: 16px;
  color: #333;
}
h1 { margin: 20px; font-size: 65px; font-weight: bold; }
header a { margin: 0 10px; text-decoration: none; color: #333; font-weight: bold; }
.logged-in-status { margin: 0 10px 0 30px; }
</style>
```
- make `frontend/store/index.js` look like this:
```
export default {
  state: () => ({
  })
}
```
- make `frontend/pages/index.vue` look like this:
```
<template>
  <h1>{{title}}</h1>
</template>

<script>
export default {
  data() {
    return {
      title: 'Home'
    }
  }
}
</script>
```
- make `frontend/pages/public-content.vue` look like this:
```
<template>
  <div>
    <h1>{{title}}</h1>
    <v-simple-table>
      <template v-slot:default>
        <tbody>
          <tr
            v-for="item in contents"
            :key="item.id"
          >
            <td>{{ item.name }}</td>
          </tr>
        </tbody>
      </template>
    </v-simple-table>
  </div>
</template>

<script>
export default {
  data () {
    return {
      title: 'Public Content',
      contents: []
    }
  },
  methods: {
    async updateContent() {
      this.contents = await this.$axios.$get('/public_contents');
    }
  },
  mounted () {
    this.updateContent();
  }
}
</script>
```
- Open `frontend/pages/private-content.vue` and make it look like this
```
<template>
  <div>
    <h1>{{title}}</h1>
    <v-simple-table>
      <template v-slot:default>
        <tbody>
          <tr
            v-for="item in contents"
            :key="item.id"
          >
            <td>{{ item.name }}</td>
          </tr>
        </tbody>
      </template>
    </v-simple-table>
  </div>
</template>

<script>
export default {
  data () {
    return {
      title: 'Private Content',
      contents: []
    }
  },
  methods: {
    async updateContent() {
      this.contents = await this.$axios.$get('/private_contents');
    }
  },
  mounted () {
    this.updateContent();
  }
}
</script>
```
- Open the `frontend/pages/log-in.vue` and make it look like this:
```
<template>
  <v-layout>
    <v-flex>
      <Title :title="title"></Title>
      <v-card class="form-card" v-if="$auth.$state.loggedIn">
        <v-alert v-if="!!error" type="error">{{error}}</v-alert>
        <v-card-text>
          Logged in as {{$auth.state.user.email}}
        </v-card-text>
        <v-card-actions>
          <v-btn @click="logout">Log out</v-btn>
        </v-card-actions>
      </v-card>
      <v-card v-else class="form-card">
        <v-alert v-if="!!error" type="error">{{error}}</v-alert>
        <v-card-text>
          <v-form>
            <v-text-field v-model="email" label="Email" />
            <v-text-field v-model="password" label="Password" type="password" />
          </v-form>
          <v-card-actions>
            <v-btn @click="login">Log in</v-btn>
          </v-card-actions>
        </v-card-text>
      </v-card>
    </v-flex>
  </v-layout>
</template>

<script>
export default {
  data () {
    return {
      title: 'Log In',
      email: '',
      password: '',
      error: null,
      value: ''
    }
  },
  methods: {
    login: function () {
      this.$auth.login({
        data: {
          user: {
            email: this.email,
            password: this.password
          }
        }
      }).then((response) => {
        const token = response.headers.authorization.trim();
        this.$auth.setUserToken(token)
      }).catch(e => {console.log(e)})
    },
    logout: function () {
      this.$auth.logout().catch(e => {this.error = e + ''})
    }
  }
}
</script>

<style>
.form-card {
  margin-top: 20px;
}
.logged-in-as {
  padding: 20px;
}
</style>
```
- Open the `frontend/pages/sign-up.vue` and make it look like this:
```
<template>
  <v-layout>
    <v-flex>
      <h1>{{title}}</h1>
      <v-card class="form-card" v-if="$auth.$state.loggedIn">
        <v-alert v-if="!!error" type="error">{{error}}</v-alert>
        <v-card-text>
          Logged in as {{$auth.state.user.email}}
        </v-card-text>
        <v-card-actions>
          <v-btn @click="logout">Log out</v-btn>
        </v-card-actions>
      </v-card>
      <v-card v-else class="form-card">
        <v-alert v-if="!!error" type="error">{{error}}</v-alert>
        <v-card-text>
          <v-form>
            <v-text-field v-model="email" label="Email" />
            <v-text-field v-model="password" label="Password" type="password" />
          </v-form>
          <v-card-actions>
            <v-btn @click="signup">Sign Up</v-btn>
          </v-card-actions>
        </v-card-text>
      </v-card>
    </v-flex>
  </v-layout>
</template>

<script>
export default {
  data () {
    return {
      title: 'Sign Up',
      email: '',
      password: '',
      error: null,
      value: ''
    }
  },
  methods: {
    async signup() {
      try {
        await this.$axios.$post('signup', {
          user: { email: this.email, password: this.password }
        })
        .then(() => { 
          this.$auth.login({
            data: {
              user: {
                email: this.email,
                password: this.password
              }
            }
          }).then((response) => {
            const token = response.headers.authorization.trim();
            console.log(token)
            this.$auth.setUserToken(token)
          })
        });
      } catch(e) {
        this.error = e + ''
      }
    },
    logout: function () {
      this.$auth.logout().catch(e => {this.error = e + ''})
    }
  }
}
</script>

<style>
.form-card {
  margin-top: 20px;
}
</style>
```
- make sure `rails s` is still running in a different terminal tab
- and in this terminal tab, run `yarn dev`
  - if `yarn dev` throws an error (`ERR_OSSL_EVP_UNSUPPORTED`), just run `export NODE_OPTIONS=--openssl-legacy-provider` (see https://stackoverflow.com/a/69746937) and then run `yarn dev` again
- in a browser, go to the url outputted from `yarn dev`, ie `localhost:<random port num>` - the app frontend should load

### Test The App
- Go to `localhost:<port>/public-content` - you should see some public contents
- Go to `localhost:<port>/private-content` - you should only see the page title and in the console you should see a 401 error
- Log in as `test@mail.com` / `password` - the nav should now say `Logged in as test@mail.com`
- Go to `localhost:<port>/private-content` - you should now see some private contents
- click `Log Out` - the nav should now say `Not logged in`

### Fix Private Content Nav Item
- add `v-if="$auth.$state.loggedIn"` to line 9 of `frontend/layouts/default.vue` so it now looks like this:
```
<NuxtLink v-if="$auth.$state.loggedIn" to="/private-content">Private Content</NuxtLink>`
``` 
- Now `Private Content` should show in the nav only if you're logged in

### Deploy To Heroku
- `cd` into the `frontend` folder
- `yarn clean`
- `yarn build`
- `yarn copy`
- `cd` into app's main, top level folder
- `git add .`
- `git commit -m "init"`
- `heroku login` -> any key -> login on webpage
  - if `heroku login` gives you an `--openssl-legacy-provider is not allowed in NODE_OPTIONS` error, run `unset NODE_OPTIONS` and then run `heroku login` again
- `heroku create`
- in `frontend/nuxt.config.js` change the <heroku app name> in the last url in line 30 to the app name outputted in the above `heroku create` (ie, `thawing-headland-13757`)
- `yarn clean`
- `yarn build`
- `yarn copy`
- `cd` into the `backend` folder
- `bundle lock --add-platform x86_64-linux`
- `cd` into main app root folder
- `git add .`
- `git commit -m "updated heroku app name in nuxt.config.js axios setting"`
- `cd` into `backend` folder
- `heroku config`
- `EDITOR='code --wait' rails credentials:edit` -> copy secret keybase string
- `heroku config:set SECRET_KEYBASE=<secret keybase copied above>`
- copy master key from `backend/config/master.key`
- ``heroku config:set RAILS_MASTER_KEY=`cat config/master.key` --app '<heroku app name>'``
- `cd` into main app root folder
- `git subtree push --prefix backend heroku main`
- `heroku run rake db:migrate`
- `heroku run rake db:seed`
- `heroku ps:scale web=1`
- `heroku open`

