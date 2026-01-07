<script setup>
import { ref, onMounted, nextTick } from 'vue'
import { createSession, sendMessage, generateNewSessionId } from '../api'

const messages = ref([])

const userInput = ref('')
const isLoading = ref(false)
const scrollContainer = ref(null)
const sessionId = ref(generateNewSessionId())

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
    console.log('Session initialized:', sessionId.value)
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
        text: "I've received your data. Analyzing it now..." 
      })
    }
  } catch (err) {
    console.error('API Error:', err)
    messages.value.push({ 
      role: 'error', 
      text: "Connection error. Please check your backend and try again." 
    })
  } finally {
    isLoading.value = false
    scrollToBottom()
  }
}
</script>

<template>
  <div id="chat-interface" class="flex-1 flex flex-col bg-white/20 backdrop-blur-xl rounded-3xl shadow-2xl overflow-hidden border border-white/30">
    <!-- Messages Area -->
    <div ref="scrollContainer" id="message-container" class="flex-1 overflow-y-auto p-6 space-y-6 scrollbar-hide">
      <TransitionGroup name="message">
        <div v-for="(msg, i) in messages" :key="i" 
             :id="`message-${i}`"
             :class="[
               'max-w-[85%] p-5 rounded-3xl shadow-lg text-sm md:text-base leading-relaxed transition-all duration-300',
               msg.role === 'user' 
                 ? 'ml-auto bg-gradient-to-br from-london-blue to-blue-900 text-white rounded-br-none' 
                 : msg.role === 'error'
                   ? 'mx-auto bg-red-500/90 text-white border border-red-400 text-center backdrop-blur-md'
                   : 'bg-white/90 text-slate-800 rounded-bl-none border border-white/50 backdrop-blur-md'
             ]">
          <div class="font-bold mb-1 opacity-70 text-[10px] uppercase tracking-tighter">
            {{ msg.role === 'user' ? 'You' : 'Lyla' }}
          </div>
          <div class="whitespace-pre-wrap font-medium">{{ msg.text }}</div>
        </div>
      </TransitionGroup>
      
      <!-- Typing Indicator -->
      <div v-if="isLoading" id="typing-indicator" class="bg-white/80 border border-white/50 p-5 rounded-2xl rounded-bl-none shadow-md w-20 backdrop-blur-md">
        <div class="flex gap-1.5 justify-center">
          <div class="w-1.5 h-1.5 bg-london-blue rounded-full animate-bounce"></div>
          <div class="w-1.5 h-1.5 bg-london-blue rounded-full animate-bounce [animation-delay:0.2s]"></div>
          <div class="w-1.5 h-1.5 bg-london-blue rounded-full animate-bounce [animation-delay:0.4s]"></div>
        </div>
      </div>
    </div>

    <!-- Input Area -->
    <div class="p-6 bg-white/40 backdrop-blur-md border-t border-white/20">
      <div class="flex gap-4 items-center">
        <button 
          id="clear-button"
          @click="clearSession"
          class="flex flex-col items-center gap-1 group"
          title="Clear session"
        >
          <div class="w-12 h-12 rounded-xl bg-white/50 border border-white/50 flex items-center justify-center hover:bg-white transition-all group-active:scale-95 shadow-sm">
            <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor" class="w-5 h-5 text-slate-500">
              <path stroke-linecap="round" stroke-linejoin="round" d="M16.023 9.348h4.992v-.001M2.985 19.644v-4.992m0 0h4.992m-4.993 0l3.181 3.183a8.25 8.25 0 0013.803-3.7M4.031 9.865a8.25 8.25 0 0113.803-3.7l3.181 3.182m0-4.991v4.99" />
            </svg>
          </div>
          <span class="text-[9px] font-bold text-slate-400 uppercase tracking-widest">Clear</span>
        </button>

        <form @submit.prevent="handleSend" class="relative group flex-1">
          <input 
            id="user-input"
            v-model="userInput"
            type="text" 
            placeholder="Where to next in London?"
            class="w-full pl-6 pr-16 py-5 rounded-2xl bg-white/80 border border-white/50 text-slate-800 placeholder:text-slate-400 focus:outline-none focus:ring-4 focus:ring-london-blue/20 transition-all shadow-inner"
            :disabled="isLoading"
          />
          <button 
            id="send-button"
            type="submit"
            class="absolute right-2 top-2 bottom-2 aspect-square bg-london-red text-white rounded-xl flex items-center justify-center hover:scale-105 active:scale-95 transition-all shadow-lg disabled:opacity-30 disabled:hover:scale-100"
            :disabled="isLoading || !userInput.trim()"
          >
            <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="2.5" stroke="currentColor" class="w-6 h-6">
              <path stroke-linecap="round" stroke-linejoin="round" d="M6 12L3.269 3.126A59.768 59.768 0 0121.485 12 59.77 59.77 0 013.27 20.876L5.999 12zm0 0h7.5" />
            </svg>
          </button>
        </form>
      </div>
      <div class="mt-3 text-[10px] text-center text-slate-500 font-bold uppercase tracking-widest opacity-60">
        AI-Powered Concierge Service • Session: {{ sessionId }}
      </div>
    </div>
  </div>
</template>

<style scoped>
.message-enter-active,
.message-leave-active {
  transition: all 0.4s cubic-bezier(0.175, 0.885, 0.32, 1.275);
}
.message-enter-from {
  opacity: 0;
  transform: translateY(20px) scale(0.9);
}
.scrollbar-hide::-webkit-scrollbar {
  display: none;
}
.scrollbar-hide {
  -ms-overflow-style: none;
  scrollbar-width: none;
}
</style>
