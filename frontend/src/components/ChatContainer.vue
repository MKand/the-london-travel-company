<script setup>
import { ref, onMounted, nextTick } from 'vue'
import { createSession, sendMessage, generateNewSessionId } from '../api'

const messages = ref([])
const userInput = ref('')
const isLoading = ref(false)
const scrollContainer = ref(null)
const sessionId = ref(generateNewSessionId())

const loadingMessages = [
  "Cymbal is curating your journey...",
  "Consulting the London archives...",
  "Finding the perfect spots for you..."
]
const currentLoadingMessage = ref(loadingMessages[0])
let loadingInterval = null

const scrollToBottom = async () => {
  await nextTick()
  if (scrollContainer.value) {
    scrollContainer.value.scrollTo({
      top: scrollContainer.value.scrollHeight,
      behavior: 'smooth'
    })
  }
}

const initializeSession = async () => {
  try {
    await createSession(sessionId.value)
  } catch (err) {
    console.error('Failed to initialize session:', err)
  }
}

onMounted(initializeSession)

const clearSession = async () => {
  sessionId.value = generateNewSessionId()
  messages.value = []
  await initializeSession()
}

const handleSend = async () => {
  if (!userInput.value.trim() || isLoading.value) return
  
  const text = userInput.value.trim()
  userInput.value = ''
  
  messages.value.push({ role: 'user', text })
  scrollToBottom()
  
  isLoading.value = true
  let msgIndex = 0
  loadingInterval = setInterval(() => {
    msgIndex = (msgIndex + 1) % loadingMessages.length
    currentLoadingMessage.value = loadingMessages[msgIndex]
  }, 2500)

  try {
    const events = await sendMessage(sessionId.value, text)
    
    let responseText = ''
    events.forEach(event => {
      if (event.content && event.content.role === 'model') {
        event.content.parts.forEach(part => {
          if (part.text) responseText += part.text
        })
      }
    })

    if (responseText) {
      messages.value.push({ 
        role: 'assistant', 
        text: responseText
      })
    } else {
       messages.value.push({ 
        role: 'assistant', 
        text: "I've analyzed your request. What else would you like to know about London?" 
      })
    }
  } catch (err) {
    console.error('API Error:', err)
    messages.value.push({ 
      role: 'error', 
      text: "I'm having trouble connecting to the Agent. Please try again in a moment." 
    })
  } finally {
    isLoading.value = false
    clearInterval(loadingInterval)
    scrollToBottom()
  }
}
</script>

<template>
  <div id="chat-interface" class="flex-1 flex flex-col h-full bg-slate-900/95 backdrop-blur-3xl rounded-[3rem] shadow-[0_40px_100px_-20px_rgba(0,0,0,0.8)] overflow-hidden border border-white/20 ring-1 ring-white/10">
    <!-- Header -->
    <div class="px-10 py-8 border-b border-white/10 bg-white/10 flex items-center justify-between">
      <div class="flex items-center gap-6">
        <div class="flex items-center gap-2.5">
          <div class="w-2.5 h-2.5 rounded-full bg-emerald-400 shadow-[0_0_15px_rgba(52,211,153,0.8)] animate-pulse"></div>
          <span class="text-[10px] font-black uppercase tracking-[0.3em] text-white/90">Cymbal London Concierge</span>
        </div>
        <div class="w-px h-3 bg-white/10"></div>
        <button @click="clearSession" class="text-[10px] font-black uppercase tracking-widest text-white/40 hover:text-london-red transition-all hover:scale-105 active:scale-95">
          Reset Session
        </button>
      </div>
    </div>

    <!-- Messages Area -->
    <div ref="scrollContainer" id="message-container" class="flex-1 overflow-y-auto p-10 space-y-10 scrollbar-hide">
      <div v-if="messages.length === 0" class="h-full flex flex-col items-center justify-center text-center space-y-6 opacity-30">
        <div class="w-20 h-20 bg-white/5 rounded-[2rem] flex items-center justify-center border border-white/10 shadow-inner">
          <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="w-10 h-10">
            <path stroke-linecap="round" stroke-linejoin="round" d="M8.625 12a.375.375 0 11-.75 0 .375.375 0 01.75 0zm0 0H8.25m4.125 0a.375.375 0 11-.75 0 .375.375 0 01.75 0zm0 0H12m4.125 0a.375.375 0 11-.75 0 .375.375 0 01.75 0zm0 0h-.375M21 12c0 4.556-4.03 8.25-9 8.25a9.764 9.764 0 01-2.555-.337A5.972 5.972 0 015.41 20.97a5.969 5.969 0 01-.474-.065 4.48 4.48 0 00.978-2.025c.09-.457-.133-.901-.467-1.226C3.93 16.178 3 14.189 3 12c0-4.556 4.03-8.25 9-8.25s9 3.694 9 8.25z" />
          </svg>
        </div>
        <div class="space-y-2">
           <p class="text-[11px] font-black uppercase tracking-[0.2em]">Start Planning</p>
           <p class="text-sm font-medium max-w-[220px]">How can I help you explore London today?</p>
        </div>
      </div>

      <TransitionGroup name="message">
        <div v-for="(msg, i) in messages" :key="i" 
             :class="[
               'max-w-[88%] p-8 rounded-[2.5rem] text-sm md:text-base leading-relaxed transition-all duration-700 shadow-2xl border',
               msg.role === 'user' 
                 ? 'ml-auto bg-london-blue text-white rounded-tr-none border-white/10 shadow-[0_20px_40px_-10px_rgba(0,54,136,0.6)]' 
                 : msg.role === 'error'
                   ? 'mx-auto bg-red-500/20 text-red-100 border-red-500/40 text-center backdrop-blur-3xl px-10'
                   : 'bg-white/10 text-white rounded-tl-none border-white/20 backdrop-blur-[80px] shadow-[inset_0_2px_10px_rgba(255,255,255,0.15)]'
             ]">
          <div :class="['font-black mb-3 text-[9px] uppercase tracking-[0.3em]', msg.role === 'user' ? 'text-white/40' : 'text-london-red']">
            {{ msg.role === 'user' ? 'Traveler' : 'Cymbal' }}
          </div>
          <div class="whitespace-pre-wrap font-medium drop-shadow-md text-white">{{ msg.text }}</div>
        </div>
      </TransitionGroup>
      
      <!-- Typing Indicator -->
      <div v-if="isLoading" class="flex items-center gap-6 bg-white/10 border border-white/20 p-6 px-10 rounded-[2.5rem] rounded-tl-none shadow-3xl backdrop-blur-3xl animate-in fade-in slide-in-from-left-6 duration-700">
        <div class="flex gap-2">
          <div class="w-2 h-2 bg-london-red rounded-full animate-bounce [animation-delay:-0.3s] shadow-[0_0_15px_rgba(223,27,18,1)]"></div>
          <div class="w-2 h-2 bg-london-red rounded-full animate-bounce [animation-delay:-0.15s] shadow-[0_0_15px_rgba(223,27,18,1)]"></div>
          <div class="w-2 h-2 bg-london-red rounded-full animate-bounce shadow-[0_0_15px_rgba(223,27,18,1)]"></div>
        </div>
        <span class="text-xs font-bold text-white/80 tracking-wider italic">{{ currentLoadingMessage }}</span>
      </div>
    </div>

    <!-- Input Area -->
    <div class="p-10 bg-black/60 backdrop-blur-[80px] border-t border-white/10 space-y-4">
      <form @submit.prevent="handleSend" class="relative group">
        <input 
          v-model="userInput"
          type="text" 
          placeholder="Ask Cymbal anything about London..."
          class="w-full pl-10 pr-20 py-7 rounded-3xl bg-white/10 border border-white/20 text-white placeholder:text-white/30 focus:outline-none focus:ring-4 focus:ring-london-red/30 transition-all shadow-2xl focus:bg-white/15 text-base"
          :disabled="isLoading"
        />
        <button 
          type="submit"
          class="absolute right-4 top-4 bottom-4 aspect-square bg-london-red text-white rounded-2xl flex items-center justify-center hover:scale-110 active:scale-95 transition-all shadow-[0_15px_30px_-5px_rgba(223,27,18,0.8)] disabled:opacity-20 group/btn"
          :disabled="isLoading || !userInput.trim()"
        >
          <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="3.5" stroke="currentColor" class="w-6 h-6 group-hover/btn:translate-x-1 transition-transform">
            <path stroke-linecap="round" stroke-linejoin="round" d="M13.5 4.5L21 12m0 0l-7.5 7.5M21 12H3" />
          </svg>
        </button>
      </form>
      <div class="text-[9px] text-center font-black uppercase tracking-[0.4em] text-white/30">
        AI Concierge Service • Powered by Gemini
      </div>
    </div>
  </div>
</template>

<style scoped>
.message-enter-active {
  transition: all 0.8s cubic-bezier(0.34, 1.56, 0.64, 1);
}
.message-enter-from {
  opacity: 0;
  transform: translateY(40px) scale(0.85) rotate(-2deg);
}
.scrollbar-hide::-webkit-scrollbar {
  display: none;
}
.scrollbar-hide {
  -ms-overflow-style: none;
  scrollbar-width: none;
}
</style>
