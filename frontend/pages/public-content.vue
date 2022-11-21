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