<script setup>
import ChatContainer from './components/ChatContainer.vue'
</script>

<template>
  <div class="fixed inset-0 w-full h-full bg-cover bg-center z-[-1]" style="background-image: url('/images/bg.png'); filter: brightness(0.85);"></div>
  
  <div class="min-h-screen flex flex-col font-inter">
    <header class="sticky top-0 z-10 backdrop-blur-md bg-white/70 border-b border-white/20 p-6">
      <div class="max-w-5xl mx-auto flex items-center justify-between">
        <div class="flex items-center gap-4">
          <div class="w-12 h-12 bg-london-red rounded-xl flex items-center justify-center shadow-lg transform rotate-3 hover:rotate-0 transition-transform">
            <span class="text-white font-black text-2xl">L</span>
          </div>
          <div>
            <h1 class="text-2xl font-black text-london-blue tracking-tight">LYLA</h1>
            <p class="text-sm font-medium text-slate-500 uppercase tracking-widest">London Expert Assistant</p>
          </div>
        </div>
        
        <div class="hidden md:flex gap-6 text-sm font-bold text-slate-600">
          <span class="hover:text-london-red cursor-pointer transition-colors">ATTRACTIONS</span>
          <span class="hover:text-london-red cursor-pointer transition-colors">ITINERARIES</span>
          <span class="hover:text-london-red cursor-pointer transition-colors">BOOKINGS</span>
        </div>
      </div>
    </header>

    <div class="max-w-5xl mx-auto w-full px-8 pt-12 pb-6 text-center md:text-left">
      <h2 class="text-4xl md:text-5xl font-black text-white drop-shadow-lg mb-4">
        Welcome to <span class="text-london-red">London</span>.
      </h2>
      <p class="text-lg md:text-xl font-medium text-white/90 drop-shadow-md max-w-2xl leading-relaxed">
        I'm Lyla, your personal concierge. I can curate a bespoke itinerary, find the best afternoon tea spots, or guide you through London's hidden history. How can I assist you today?
      </p>
    </div>

    <main class="flex-1 flex flex-col overflow-hidden max-w-5xl mx-auto w-full p-4 md:p-8 pt-0 md:pt-0">
      <ChatContainer />
    </main>

    <footer class="p-6 text-center text-sm font-medium text-slate-400 bg-white/30 backdrop-blur-sm border-t border-white/10">
      © 2026 THE LONDON TRAVEL COMPANY • ALL RIGHTS RESERVED
    </footer>
  </div>
</template>

<style>
/* Any global styles if needed */
</style>
