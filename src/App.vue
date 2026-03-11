<script setup>
import { computed, onMounted, onUnmounted, reactive, ref } from 'vue'
import { supabase } from './lib/supabase'
import todoShowcaseImage from '../docs/img/todoimg.jpeg'

const authMode = ref('login')
const session = ref(null)
const authLoading = ref(true)
const authSubmitting = ref(false)
const authError = ref('')
const authMessage = ref('')

const todosLoading = ref(false)
const todosError = ref('')
const todos = ref([])

const sortBy = ref('created_at')
const editorOpen = ref(false)
const editorMode = ref('create')
const savingTodo = ref(false)
const deletingId = ref('')
const togglingId = ref('')
const draggingTodoId = ref('')
const dragOverColumnKey = ref('')

const authForm = reactive({
  email: '',
  password: '',
})

const todoForm = reactive({
  id: '',
  title: '',
  description: '',
  priority: 'medium',
  due_date: '',
  status: 'pending',
})

const boardColumns = computed(() => {
  const sorted = [...todos.value].sort((left, right) => {
    if (sortBy.value === 'due_date') {
      const leftDate = left.due_date || '9999-12-31'
      const rightDate = right.due_date || '9999-12-31'
      return leftDate.localeCompare(rightDate)
    }

    return new Date(right.created_at) - new Date(left.created_at)
  })

  return [
    {
      key: 'high',
      title: 'Alta',
      tone: 'lavender',
      count: sorted.filter((todo) => todo.status === 'pending' && todo.priority === 'high')
        .length,
      items: sorted.filter((todo) => todo.status === 'pending' && todo.priority === 'high'),
    },
    {
      key: 'medium',
      title: 'Media',
      tone: 'sky',
      count: sorted.filter((todo) => todo.status === 'pending' && todo.priority === 'medium')
        .length,
      items: sorted.filter((todo) => todo.status === 'pending' && todo.priority === 'medium'),
    },
    {
      key: 'low',
      title: 'Baja',
      tone: 'sand',
      count: sorted.filter((todo) => todo.status === 'pending' && todo.priority === 'low')
        .length,
      items: sorted.filter((todo) => todo.status === 'pending' && todo.priority === 'low'),
    },
    {
      key: 'completed',
      title: 'Hechas',
      tone: 'rose',
      count: sorted.filter((todo) => todo.status === 'completed').length,
      items: sorted.filter((todo) => todo.status === 'completed'),
    },
  ]
})

const counts = computed(() => ({
  total: todos.value.length,
  pending: todos.value.filter((todo) => todo.status === 'pending').length,
  completed: todos.value.filter((todo) => todo.status === 'completed').length,
}))

const userEmail = computed(() => session.value?.user?.email || '')
const isAuthenticated = computed(() => Boolean(session.value?.user))

function resetTodoForm() {
  todoForm.id = ''
  todoForm.title = ''
  todoForm.description = ''
  todoForm.priority = 'medium'
  todoForm.due_date = ''
  todoForm.status = 'pending'
}

function openCreateEditor(priority = 'medium') {
  editorMode.value = 'create'
  resetTodoForm()
  todoForm.priority = priority
  editorOpen.value = true
}

function openEditEditor(todo) {
  editorMode.value = 'edit'
  todoForm.id = todo.id
  todoForm.title = todo.title
  todoForm.description = todo.description || ''
  todoForm.priority = todo.priority
  todoForm.due_date = todo.due_date || ''
  todoForm.status = todo.status
  editorOpen.value = true
}

function closeEditor() {
  editorOpen.value = false
  resetTodoForm()
}

function getColumnPayload(columnKey, todo) {
  if (columnKey === 'completed') {
    return {
      status: 'completed',
      priority: todo.priority,
      completed_at: todo.completed_at || new Date().toISOString(),
    }
  }

  return {
    status: 'pending',
    priority: columnKey,
    completed_at: null,
  }
}

function handleDragStart(todo) {
  draggingTodoId.value = todo.id
}

function handleDragEnd() {
  draggingTodoId.value = ''
  dragOverColumnKey.value = ''
}

function handleColumnDragOver(columnKey) {
  dragOverColumnKey.value = columnKey
}

function handleColumnDragLeave(columnKey) {
  if (dragOverColumnKey.value === columnKey) {
    dragOverColumnKey.value = ''
  }
}

async function moveTodoToColumn(columnKey) {
  if (!draggingTodoId.value) return

  const todo = todos.value.find((item) => item.id === draggingTodoId.value)

  if (!todo) {
    handleDragEnd()
    return
  }

  const payload = getColumnPayload(columnKey, todo)
  const isSameColumn =
    todo.status === payload.status &&
    todo.priority === payload.priority &&
    Boolean(todo.completed_at) === Boolean(payload.completed_at)

  if (isSameColumn) {
    handleDragEnd()
    return
  }

  togglingId.value = todo.id
  todosError.value = ''

  const { error } = await supabase.from('todos').update(payload).eq('id', todo.id)

  if (error) {
    todosError.value = error.message
  } else {
    await fetchTodos()
  }

  togglingId.value = ''
  handleDragEnd()
}

async function initializeSession() {
  authLoading.value = true
  authError.value = ''

  const [{ data, error }, subscription] = await Promise.all([
    supabase.auth.getSession(),
    Promise.resolve(
      supabase.auth.onAuthStateChange((_event, nextSession) => {
        session.value = nextSession
        if (nextSession?.user) {
          fetchTodos()
        } else {
          todos.value = []
          closeEditor()
        }
      }),
    ),
  ])

  if (error) {
    authError.value = error.message
  } else {
    session.value = data.session
    if (data.session?.user) {
      await fetchTodos()
    }
  }

  authLoading.value = false
  return subscription.data.subscription
}

async function handleAuthSubmit() {
  authSubmitting.value = true
  authError.value = ''
  authMessage.value = ''

  const email = authForm.email.trim()
  const password = authForm.password

  if (!email || !password) {
    authError.value = 'El correo y la contrasena son obligatorios.'
    authSubmitting.value = false
    return
  }

  const authCall =
    authMode.value === 'login'
      ? supabase.auth.signInWithPassword({ email, password })
      : supabase.auth.signUp({ email, password })

  const { data, error } = await authCall

  if (error) {
    authError.value = error.message
  } else if (authMode.value === 'register' && !data.session) {
    authMessage.value =
      'Cuenta creada. Revisa tu correo si la confirmacion por email esta activada en Supabase.'
  } else {
    authForm.password = ''
  }

  authSubmitting.value = false
}

async function handleLogout() {
  authError.value = ''
  authMessage.value = ''
  const { error } = await supabase.auth.signOut()

  if (error) {
    authError.value = error.message
  }
}

async function fetchTodos() {
  if (!session.value?.user) return

  todosLoading.value = true
  todosError.value = ''

  const { data, error } = await supabase
    .from('todos')
    .select('*')
    .order(sortBy.value === 'due_date' ? 'due_date' : 'created_at', {
      ascending: sortBy.value === 'due_date',
      nullsFirst: false,
    })

  if (error) {
    todosError.value = error.message
    todos.value = []
  } else {
    todos.value = data || []
  }

  todosLoading.value = false
}

async function saveTodo() {
  if (!session.value?.user) return

  savingTodo.value = true
  todosError.value = ''

  const payload = {
    title: todoForm.title.trim(),
    description: todoForm.description.trim() || null,
    priority: todoForm.priority,
    due_date: todoForm.due_date || null,
    status: todoForm.status,
    completed_at: todoForm.status === 'completed' ? new Date().toISOString() : null,
    user_id: session.value.user.id,
  }

  if (!payload.title) {
    todosError.value = 'El titulo es obligatorio.'
    savingTodo.value = false
    return
  }

  let response

  if (editorMode.value === 'create') {
    response = await supabase.from('todos').insert(payload)
  } else {
    response = await supabase.from('todos').update(payload).eq('id', todoForm.id)
  }

  if (response.error) {
    todosError.value = response.error.message
  } else {
    closeEditor()
    await fetchTodos()
  }

  savingTodo.value = false
}

async function toggleTodo(todo) {
  togglingId.value = todo.id
  todosError.value = ''

  const nextStatus = todo.status === 'completed' ? 'pending' : 'completed'
  const { error } = await supabase
    .from('todos')
    .update({
      status: nextStatus,
      completed_at: nextStatus === 'completed' ? new Date().toISOString() : null,
    })
    .eq('id', todo.id)

  if (error) {
    todosError.value = error.message
  } else {
    await fetchTodos()
  }

  togglingId.value = ''
}

async function deleteTodo(todo) {
  deletingId.value = todo.id
  todosError.value = ''

  const { error } = await supabase.from('todos').delete().eq('id', todo.id)

  if (error) {
    todosError.value = error.message
  } else {
    if (todoForm.id === todo.id) closeEditor()
    await fetchTodos()
  }

  deletingId.value = ''
}

function formatDate(dateString) {
  if (!dateString) return 'Sin fecha'

  return new Intl.DateTimeFormat('es-ES', {
    day: '2-digit',
    month: 'short',
  }).format(new Date(dateString))
}

function initials(email) {
  return email.slice(0, 2).toUpperCase()
}

let authSubscription

onMounted(async () => {
  authSubscription = await initializeSession()
})

onUnmounted(() => {
  authSubscription?.unsubscribe()
})
</script>

<template>
  <main class="app-shell">
    <section v-if="authLoading" class="panel loading-panel">
      <h1>Conectando tu espacio de trabajo...</h1>
      <p class="subtle">Cargando sesion y datos del tablero desde Supabase.</p>
    </section>

    <section v-else-if="!isAuthenticated" class="auth-scene">
      <div class="auth-showcase">
        <div class="showcase-panel">
          <h1>Organiza tu dia con un tablero claro, rapido y visual.</h1>
          <p class="subtle">
            Crea tareas, prioriza lo importante y sigue tu progreso en un espacio
            privado pensado para trabajar sin friccion.
          </p>
          <img class="auth-showcase-image" :src="todoShowcaseImage" alt="Vista previa del tablero to-do" />
        </div>
      </div>

      <div class="auth-panel">
        <div class="auth-tabs">
          <button class="tab-button" :class="{ active: authMode === 'login' }" @click="authMode = 'login'">
            Entrar
          </button>
          <button
            class="tab-button"
            :class="{ active: authMode === 'register' }"
            @click="authMode = 'register'"
          >
            Registro
          </button>
        </div>

        <form class="form-stack" @submit.prevent="handleAuthSubmit">
          <label class="field">
            <span>Correo</span>
            <input v-model="authForm.email" type="email" placeholder="tu@email.com" />
          </label>

          <label class="field">
            <span>Contrasena</span>
            <input v-model="authForm.password" type="password" placeholder="Minimo 6 caracteres" />
          </label>

          <p v-if="authError" class="feedback error">{{ authError }}</p>
          <p v-if="authMessage" class="feedback success">{{ authMessage }}</p>

          <button class="primary-action" type="submit" :disabled="authSubmitting">
            {{ authSubmitting ? 'Procesando...' : authMode === 'login' ? 'Entrar al tablero' : 'Crear cuenta' }}
          </button>
        </form>
      </div>
    </section>

    <section v-else class="workspace">
      <header class="workspace-header">
        <div class="workspace-brand">
          <div>
            <h1>Tablero de tareas</h1>
          </div>
          <p class="subtle">{{ counts.total }} tarjetas en tu espacio privado</p>
        </div>

        <div class="workspace-actions">
          <div class="user-badge">{{ initials(userEmail) }}</div>
          <div class="user-copy">
            <strong>{{ userEmail }}</strong>
            <span>Protegido con Supabase</span>
          </div>
          <button class="soft-action" @click="openCreateEditor()">Anadir tarea</button>
          <button class="ghost-action" @click="handleLogout">Cerrar sesion</button>
        </div>
      </header>

      <section class="workspace-meta">
        <div class="search-shell">
          <input readonly value="La busqueda queda reservada para la siguiente iteracion" />
        </div>

        <div class="meta-pills">
          <span class="meta-pill">Pendientes {{ counts.pending }}</span>
          <span class="meta-pill success">Hechas {{ counts.completed }}</span>
          <label class="select-shell">
            <span>Orden</span>
            <select v-model="sortBy" @change="fetchTodos">
              <option value="created_at">Mas recientes</option>
              <option value="due_date">Fecha limite</option>
            </select>
          </label>
        </div>
      </section>

      <p v-if="todosError" class="feedback error board-error">{{ todosError }}</p>

      <section v-if="todosLoading" class="panel board-state">
        <h2>Cargando tablero...</h2>
        <p class="subtle">Recuperando filas desde tu tabla `todos`.</p>
      </section>

      <section v-else class="board-layout">
        <div class="board-scroll">
          <div
            v-for="column in boardColumns"
            :key="column.key"
            class="board-column"
            :class="[column.tone, { 'drag-over': dragOverColumnKey === column.key }]"
            @dragover.prevent="handleColumnDragOver(column.key)"
            @dragleave="handleColumnDragLeave(column.key)"
            @drop.prevent="moveTodoToColumn(column.key)"
          >
            <div class="column-header">
              <div class="column-title">
                <span class="column-count">{{ column.count }}</span>
                <h2>{{ column.title }}</h2>
              </div>
              <button
                v-if="column.key !== 'completed'"
                class="column-add"
                @click="openCreateEditor(column.key)"
              >
                +
              </button>
            </div>

            <div class="column-cards">
              <article
                v-for="todo in column.items"
                :key="todo.id"
                class="task-card"
                :class="{ dragging: draggingTodoId === todo.id }"
                draggable="true"
                @dragstart="handleDragStart(todo)"
                @dragend="handleDragEnd"
                @click="openEditEditor(todo)"
              >
                <div class="task-header">
                  <span class="task-badge" :class="todo.priority">{{ todo.priority }}</span>
                  <button
                    class="task-check"
                    :disabled="togglingId === todo.id"
                    @click.stop="toggleTodo(todo)"
                  >
                    {{ todo.status === 'completed' ? '↺' : '✓' }}
                  </button>
                </div>

                <h3>{{ todo.title }}</h3>
                <p v-if="todo.description" class="task-text">{{ todo.description }}</p>

                <div class="task-footer">
                  <span>{{ formatDate(todo.due_date || todo.created_at) }}</span>
                  <button
                    class="task-delete"
                    :disabled="deletingId === todo.id"
                    @click.stop="deleteTodo(todo)"
                  >
                    {{ deletingId === todo.id ? '...' : 'Borrar' }}
                  </button>
                </div>
              </article>

              <button
                class="column-cta"
                @click="openCreateEditor(column.key === 'completed' ? 'medium' : column.key)"
              >
                + Anadir nueva tarea
              </button>
            </div>
          </div>
        </div>

        <aside class="editor-panel">
          <div class="editor-top">
            <div>
              <p class="section-kicker">Editor de tareas</p>
              <h2>{{ editorOpen ? (editorMode === 'create' ? 'Nueva tarjeta' : 'Editar tarjeta') : 'Listo' }}</h2>
            </div>
            <button v-if="editorOpen" class="ghost-action" @click="closeEditor">Cerrar</button>
          </div>

          <div v-if="!editorOpen" class="editor-placeholder">
            <p class="subtle">
              Selecciona una tarjeta del tablero o crea una nueva desde cualquier columna.
            </p>
          </div>

          <form v-else class="form-stack" @submit.prevent="saveTodo">
            <label class="field">
              <span>Titulo</span>
              <input v-model="todoForm.title" type="text" maxlength="120" placeholder="Cerrar QA de la landing" />
            </label>

            <label class="field">
              <span>Descripcion</span>
              <textarea v-model="todoForm.description" rows="4" placeholder="Nota opcional"></textarea>
            </label>

            <div class="field-row">
              <label class="field">
                <span>Prioridad</span>
                <select v-model="todoForm.priority">
                  <option value="high">Alta</option>
                  <option value="medium">Media</option>
                  <option value="low">Baja</option>
                </select>
              </label>

              <label class="field">
                <span>Fecha limite</span>
                <input v-model="todoForm.due_date" type="date" />
              </label>
            </div>

            <label class="field">
              <span>Estado</span>
              <select v-model="todoForm.status">
                <option value="pending">Pendiente</option>
                <option value="completed">Hecha</option>
              </select>
            </label>

            <button class="primary-action" type="submit" :disabled="savingTodo">
              {{ savingTodo ? 'Guardando...' : editorMode === 'create' ? 'Crear tarjeta' : 'Guardar cambios' }}
            </button>
          </form>
        </aside>
      </section>
    </section>
  </main>
</template>
