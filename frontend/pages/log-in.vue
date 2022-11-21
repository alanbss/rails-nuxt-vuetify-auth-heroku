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