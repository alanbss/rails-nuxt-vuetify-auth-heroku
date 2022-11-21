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