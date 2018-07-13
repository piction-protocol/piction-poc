<template>
  <div>
    <img v-for="cut in cuts" :src="cut"/>
    <ul>
      <li class="list">
        <router-link :to="{ name: 'episodes', params: { content_id: content_id }}">list</router-link>
      </li>
      <li class="prev">prev</li>
      <li class="next">next</li>
    </ul>
  </div>
</template>

<script>
  export default {
    props: ['content_id', 'episode_id'],
    data() {
      return {
        cuts: [
          "http://images.battlecomics.co.kr/users/362167/page/item/60a926a2-abc4-42be-9169-636bcd765c65.jpg",
          "http://images.battlecomics.co.kr/users/362167/page/item/8db43261-28b4-4089-ba9b-21793373a378.jpg",
          "http://images.battlecomics.co.kr/users/362167/page/item/9dc81f4c-532c-4fa4-946e-023a30c71f9a.jpg",
          "http://images.battlecomics.co.kr/users/362167/page/item/a26389d5-2f31-46d6-a58c-ed74008ec621.jpg",
          "http://images.battlecomics.co.kr/users/362167/page/item/d2dda8c7-9b11-4509-9773-674e63246b44.jpg",
          "http://images.battlecomics.co.kr/users/362167/page/item/01236fb7-cb9a-4a8b-a5ad-1bee06f77c5c.jpg",
          "http://images.battlecomics.co.kr/users/362167/page/item/731ddd70-2935-41dd-a29b-dc9e46912aeb.jpg",
          "http://images.battlecomics.co.kr/users/362167/page/item/1a97c5fb-dc79-43f0-b6b6-f04b1e8d635a.jpg",
          "http://images.battlecomics.co.kr/users/362167/page/item/05847a3a-e552-4522-9914-2ece1ebad2c7.jpg",
          "http://images.battlecomics.co.kr/users/362167/page/item/c81c9c7e-cc2b-4155-a528-e09f506f9b3e.jpg",
          "http://images.battlecomics.co.kr/users/362167/page/item/99de2d42-4818-4ed5-99c4-40903825fcb0.jpg",
          "http://images.battlecomics.co.kr/users/362167/page/item/1636dae2-70e9-4850-84af-5a6abe970f81.jpg"],
      }
    },
    methods: {},
    created() {
    }
  }
</script>

<style scoped>
  div {
    text-align: center;
  }
  ul {
    background: black;
    color: white;
    list-style-type: none;
    margin: 0;
    padding: 0;
    position: fixed;
    left: 0;
    right: 0;
    height: 3rem;
    line-height: 3rem;
    bottom: 0;
  }

  ul li {
    display: block;
    float: left;
    text-align: center;
    width: 33.3%;
  }
</style>
