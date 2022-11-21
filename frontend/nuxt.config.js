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
    baseURL: dev ? 'http://localhost:3000/api' : 'https://pacific-eyrie-87021.herokuapp.com/api',
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