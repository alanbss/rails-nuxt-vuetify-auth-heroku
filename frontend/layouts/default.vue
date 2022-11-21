<template>
  <div>
    <v-layout>
      <v-flex>
        <v-toolbar>
          <v-toolbar-title><NuxtLink to="/">Cool Guy Site 😎</NuxtLink></v-toolbar-title>
          <v-spacer />
          <NuxtLink to="/public-content">Public Content</NuxtLink>
          <NuxtLink v-if="$auth.$state.loggedIn" to="/private-content">Private Content</NuxtLink>`
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