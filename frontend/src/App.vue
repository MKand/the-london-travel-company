<script setup>
import { ref } from 'vue'
import ChatContainer from './components/ChatContainer.vue'

const isChatOpen = ref(true)

const toggleChat = () => {
  isChatOpen.value = !isChatOpen.value
}

const destinations = [
  { id: 1, name: 'British Museum', category: 'History', color: 'bg-emerald-600' },
  { id: 2, name: 'Camden Market', category: 'Shopping', color: 'bg-orange-500' },
  { id: 3, name: 'London Eye', category: 'Landmark', color: 'bg-sky-500' },
  { id: 4, name: 'Afternoon Tea', category: 'Experience', color: 'bg-rose-400' },
]
</script>

<template>
  <div class="relative min-h-screen w-full overflow-x-hidden bg-london-slate text-white font-inter">
    <!-- Dark Background Layer -->
    <div class="absolute inset-0 z-0 bg-london-slate shadow-[inset_0_0_100px_rgba(0,0,0,0.5)]"></div>

    <!-- Immersive Background Image with darkness -->
    <div class="absolute inset-0 z-0 opacity-60 bg-cover bg-center bg-no-repeat" style="background-image: url('/images/bg.png'); filter: brightness(0.7) contrast(1.1);">
      <div class="absolute inset-0 bg-london-slate/40 mix-blend-multiply"></div>
      <div class="absolute inset-0 bg-gradient-to-b from-transparent via-transparent to-london-slate"></div>
    </div>

    <!-- Top Navigation -->
    <nav class="relative z-20 flex items-center justify-between px-10 py-8 backdrop-blur-md bg-white/5 border-b border-white/5">
      <div class="flex items-center gap-12">
        <div class="flex items-center gap-3">
          <div class="w-10 h-10 bg-london-red rounded-lg flex items-center justify-center transform rotate-3 shadow-lg">
            <span class="font-black text-xl text-white">C</span>
          </div>
          <span class="text-xl font-black tracking-tighter uppercase italic text-white">Cymbal London</span>
        </div>
        
        <div class="hidden lg:flex gap-10 text-xs font-black uppercase tracking-[0.3em] text-white/50">
          <a href="#" class="hover:text-london-red transition-colors">News</a>
          <a href="#" class="hover:text-london-red transition-colors">Destinations</a>
          <a href="#" class="hover:text-london-red transition-colors">Blog</a>
          <a href="#" class="hover:text-london-red transition-colors">Contact</a>
        </div>
      </div>

      <div class="flex items-center gap-8">
        <button class="w-11 h-11 rounded-full bg-white/10 flex items-center justify-center hover:bg-white/20 transition-all border border-white/10 group">
          <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="2.5" stroke="currentColor" class="w-5 h-5 text-white/70 group-hover:text-white group-hover:scale-110 transition-transform">
            <path stroke-linecap="round" stroke-linejoin="round" d="M21 21l-5.197-5.197m0 0A7.5 7.5 0 105.196 5.196a7.5 7.5 0 0010.607 10.607z" />
          </svg>
        </button>
        <div class="text-[11px] font-black text-white/80 uppercase tracking-widest hidden sm:block">
          Hello, <span class="text-london-red drop-shadow-[0_0_10px_rgba(223,27,18,0.5)]">User!</span>
        </div>
      </div>
    </nav>

    <!-- Main Content -->
    <main class="relative z-10 flex flex-col lg:flex-row min-h-[calc(100vh-100px)] max-w-7xl mx-auto px-10 pb-10 gap-10">
      
      <!-- Left Section: Hero Text -->
      <div class="flex-1 flex flex-col justify-center pt-10 lg:pt-0">
        <div class="relative">
          <h1 class="text-[10rem] lg:text-[14rem] leading-[0.8] font-black uppercase tracking-tighter opacity-5 absolute -top-10 -left-6 select-none italic text-white">
            LONDON
          </h1>
          <div class="space-y-6 relative">
            <p class="text-london-red font-black uppercase tracking-[0.5em] text-[10px] drop-shadow-sm">Experience the Extraordinary</p>
            <h2 class="text-7xl lg:text-9xl font-black uppercase tracking-tighter leading-none italic text-white drop-shadow-2xl">
              LONDON
            </h2>
            <p class="max-w-md text-base lg:text-lg text-white/60 leading-relaxed font-medium pt-4 drop-shadow-md">
              Uncover the secrets of the capital with Cymbal, your bespoke AI concierge. From hidden speakeasies to historic landmarks, we curate your perfect journey.
            </p>
            <div class="flex gap-4 pt-10">
              <button 
                @click="toggleChat"
                class="bg-london-blue text-white px-10 py-6 rounded-2xl font-black uppercase tracking-[0.2em] text-xs flex items-center gap-6 hover:bg-blue-700 transition-all shadow-[0_20px_40px_-15px_rgba(0,54,136,0.6)] hover:scale-105 active:scale-95 group"
              >
                Plan Your Trip
                <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="3" stroke="currentColor" class="w-5 h-5 group-hover:translate-x-2 transition-transform">
                  <path stroke-linecap="round" stroke-linejoin="round" d="M13.5 4.5L21 12m0 0l-7.5 7.5M21 12H3" />
                </svg>
              </button>
            </div>
          </div>
        </div>

        <!-- Destination Cards -->
        <div class="mt-20 lg:mt-32 space-y-12 max-w-5xl mx-auto">
          <div class="flex items-center justify-between border-b border-white/10 pb-6 w-full">
            <div class="flex flex-col gap-2">
              <p class="text-[10px] font-black uppercase tracking-[0.4em] text-london-red opacity-80">Explore More</p>
              <h3 class="text-3xl lg:text-4xl font-black uppercase tracking-tighter italic opacity-95">Must Visit Locations</h3>
            </div>
            <div class="flex gap-4 items-center">
              <div class="flex gap-2.5 px-4 py-2 bg-white/5 rounded-full border border-white/5">
                 <div class="w-1.5 h-1.5 rounded-full bg-london-red shadow-[0_0_10px_rgba(223,27,18,0.8)]"></div>
                 <div class="w-1.5 h-1.5 rounded-full bg-white/20"></div>
                 <div class="w-1.5 h-1.5 rounded-full bg-white/20"></div>
              </div>
            </div>
          </div>
          <div class="flex gap-10 overflow-x-auto pb-10 scrollbar-hide pt-2 snap-x scroll-smooth">
            <div v-for="dest in destinations" :key="dest.id" 
                 class="min-w-[340px] h-[460px] rounded-[3rem] relative overflow-hidden group border border-white/10 shadow-3xl transition-all duration-700 hover:-translate-y-6 hover:border-white/20 snap-center">
              <div :class="[dest.color, 'absolute inset-0 opacity-40 group-hover:opacity-60 transition-all duration-1000']"></div>
              <div class="absolute inset-0 bg-gradient-to-t from-black/95 via-black/20 to-transparent"></div>
              
              <div class="absolute top-8 right-8 bg-white/10 backdrop-blur-2xl w-14 h-14 rounded-2xl flex items-center justify-center border border-white/20 group-hover:bg-white group-hover:text-london-blue transition-all duration-500 shadow-2xl">
                <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="2.5" stroke="currentColor" class="w-6 h-6">
                  <path stroke-linecap="round" stroke-linejoin="round" d="M17.593 3.322c1.1.128 1.907 1.077 1.907 2.185V21L12 17.25 4.5 21V5.507c0-1.108.806-2.057 1.907-2.185a48.507 48.507 0 0111.186 0z" />
                </svg>
              </div>

              <div class="absolute bottom-10 left-10 space-y-3">
                <p class="text-[10px] font-black uppercase tracking-[0.5em] text-london-red drop-shadow-md">{{ dest.category }}</p>
                <h4 class="text-3xl font-black tracking-tight uppercase group-hover:scale-105 transition-transform origin-left">{{ dest.name }}</h4>
                <div class="flex gap-2 pt-2">
                  <div v-for="i in 5" :key="i" class="w-2 h-2 rounded-full bg-london-gold shadow-[0_0_8px_rgba(197,160,89,1)]"></div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>

    </main>

    <!-- Right Section: Fixed Chat Interface -->
    <transition 
      enter-active-class="transition duration-700 ease-out"
      enter-from-class="transform translate-x-32 opacity-0"
      enter-to-class="transform translate-x-0 opacity-100"
      leave-active-class="transition duration-400 ease-in"
      leave-from-class="transform translate-x-0 opacity-100"
      leave-to-class="transform translate-x-32 opacity-0"
    >
      <div v-if="isChatOpen" class="fixed top-24 right-10 z-40 w-full sm:w-[480px] h-[calc(100vh-120px)] shadow-2xl">
        <ChatContainer />
        <button 
          @click="toggleChat"
          class="absolute top-4 right-4 w-10 h-10 bg-white/10 hover:bg-white/20 rounded-xl flex items-center justify-center backdrop-blur-xl border border-white/20 transition-all shadow-xl hover:rotate-90 active:scale-90"
        >
          <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="3" stroke="currentColor" class="w-5 h-5">
            <path stroke-linecap="round" stroke-linejoin="round" d="M6 18L18 6M6 6l12 12" />
          </svg>
        </button>
      </div>
    </transition>

    <!-- Side Indicators (Left) -->
    <div class="fixed left-8 top-1/2 -translate-y-1/2 flex flex-col items-center gap-10 z-20 text-[9px] uppercase font-black tracking-[0.5em] text-white/20 hidden xl:flex">
      <div class="rotate-90 origin-center whitespace-nowrap mb-12">Discover • 01 / 04</div>
      <div class="w-[1px] h-40 bg-white/5 relative">
        <div class="absolute top-0 left-0 w-[1px] h-10 bg-london-red shadow-[0_0_10px_rgba(223,27,18,1)]"></div>
      </div>
      <div class="flex flex-col gap-6 pt-4">
        <div class="w-2 h-2 rounded-full bg-london-red shadow-[0_0_15px_rgba(223,27,18,0.8)] outline outline-2 outline-london-red/20 outline-offset-4"></div>
        <div class="w-1.5 h-1.5 rounded-full bg-white/10 hover:bg-white/30 transition-colors pointer-events-auto cursor-pointer"></div>
        <div class="w-1.5 h-1.5 rounded-full bg-white/10 hover:bg-white/30 transition-colors pointer-events-auto cursor-pointer"></div>
        <div class="w-1.5 h-1.5 rounded-full bg-white/10 hover:bg-white/30 transition-colors pointer-events-auto cursor-pointer"></div>
      </div>
    </div>
  </div>
</template>

<style>
/* Scoped styles moved to style.css for v4 consistency */
</style>
