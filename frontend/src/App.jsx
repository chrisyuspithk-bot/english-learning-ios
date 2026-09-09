import { useCallback, useEffect, useState } from 'react'
import { api, upload, getToken, setToken, clearToken } from './api'

// ---------------------------------------------------------------------------
// Shared UI
// ---------------------------------------------------------------------------

function Spinner() {
  return <div className="muted">Loading…</div>
}

function ErrorBox({ msg }) {
  return <div className="error">⚠️ {msg}</div>
}

function Modal({ title, children, onClose }) {
  return (
    <div className="modal-overlay" onClick={onClose}>
      <div className="modal" onClick={(e) => e.stopPropagation()}>
        <div className="modal-head">
          <h2>{title}</h2>
          <button className="icon-btn" onClick={onClose}>✕</button>
        </div>
        <div className="modal-body">{children}</div>
      </div>
    </div>
  )
}

function Field({ label, children }) {
  return (
    <label className="field">
      <span>{label}</span>
      {children}
    </label>
  )
}

function useAsync(fn, deps) {
  const [state, setState] = useState({ loading: true, data: null, error: null })
  const reload = useCallback(() => {
    setState((s) => ({ ...s, loading: true, error: null }))
    fn()
      .then((data) => setState({ loading: false, data, error: null }))
      .catch((err) => setState({ loading: false, data: null, error: err.message }))
  }, deps || [])
  useEffect(() => {
    reload()
  }, [reload])
  return { ...state, reload }
}

function fmtDate(d) {
  if (!d) return '—'
  return d
}

// ---------------------------------------------------------------------------
// Login
// ---------------------------------------------------------------------------

function Login({ onLogin }) {
  const [username, setUsername] = useState('admin')
  const [password, setPassword] = useState('admin123')
  const [error, setError] = useState(null)
  const [busy, setBusy] = useState(false)

  async function submit(e) {
    e.preventDefault()
    setBusy(true)
    setError(null)
    try {
      const data = await api.post('/auth/admin/login', { username, password })
      setToken(data.token)
      onLogin()
    } catch (err) {
      setError(err.message)
    } finally {
      setBusy(false)
    }
  }

  return (
    <div className="login-wrap">
      <form className="login-card" onSubmit={submit}>
        <h1>📚 English Learning Portal</h1>
        <p className="muted">Admin sign in</p>
        <Field label="Username">
          <input value={username} onChange={(e) => setUsername(e.target.value)} autoFocus />
        </Field>
        <Field label="Password">
          <input type="password" value={password} onChange={(e) => setPassword(e.target.value)} />
        </Field>
        {error && <ErrorBox msg={error} />}
        <button className="primary" disabled={busy}>{busy ? 'Signing in…' : 'Sign in'}</button>
        <p className="hint">Default demo: admin / admin123</p>
      </form>
    </div>
  )
}

// ---------------------------------------------------------------------------
// Dashboard
// ---------------------------------------------------------------------------

function Dashboard() {
  const years = useAsync(() => api.get('/admin/academic-years'), [])
  const students = useAsync(() => api.get('/admin/students'), [])
  const textbooks = useAsync(() => api.get('/admin/textbooks'), [])

  if (years.loading || students.loading || textbooks.loading) return <Spinner />
  const current = (years.data || []).find((y) => y.is_current)
  const forms = (years.data || []).flatMap((y) => [])

  const stats = [
    { label: 'Students', value: (students.data || []).length },
    { label: 'Textbooks', value: (textbooks.data || []).length },
    { label: 'Academic years', value: (years.data || []).length },
    { label: 'Current year', value: current ? current.name : '—' },
  ]

  return (
    <div>
      <h1>Dashboard</h1>
      <p className="muted">Overview of your school's English learning data.</p>
      <div className="cards">
        {stats.map((s) => (
          <div className="stat-card" key={s.label}>
            <div className="stat-value">{s.value}</div>
            <div className="stat-label">{s.label}</div>
          </div>
        ))}
      </div>
      <p className="hint">
        Use the sidebar to manage academic years → forms → classes → students, upload
        textbooks (RAG → structured chapters), and post announcements / homework.
      </p>
    </div>
  )
}

// ---------------------------------------------------------------------------
// Academic years
// ---------------------------------------------------------------------------

function AcademicYears() {
  const state = useAsync(() => api.get('/admin/academic-years'), [])
  const [show, setShow] = useState(false)

  return (
    <div>
      <Header title="Academic Years" onAdd={() => setShow(true)} />
      {state.loading ? <Spinner /> : state.error ? <ErrorBox msg={state.error} /> : (
        <Table>
          {state.data.map((y) => (
            <tr key={y.id}>
              <td>{y.name}{y.is_current && <span className="badge">current</span>}</td>
              <td>{fmtDate(y.start_date)} → {fmtDate(y.end_date)}</td>
              <td>{y.form_count} forms</td>
              <td><button className="danger" onClick={() => remove(`/admin/academic-years/${y.id}`, state.reload)}>Delete</button></td>
            </tr>
          ))}
        </Table>
      )}
      {show && <YearForm onDone={() => { setShow(false); state.reload() }} />}
    </div>
  )
}

function YearForm({ onDone }) {
  const [name, setName] = useState('')
  const [isCurrent, setIsCurrent] = useState(false)
  const [error, setError] = useState(null)

  async function save() {
    try {
      await api.post('/admin/academic-years', { name, is_current: isCurrent })
      onDone()
    } catch (e) {
      setError(e.message)
    }
  }

  return (
    <Modal title="New academic year" onClose={onDone}>
      <Field label="Name (e.g. 2026-2027)"><input value={name} onChange={(e) => setName(e.target.value)} /></Field>
      <label className="check"><input type="checkbox" checked={isCurrent} onChange={(e) => setIsCurrent(e.target.checked)} /> Set as current year</label>
      {error && <ErrorBox msg={error} />}
      <button className="primary" onClick={save}>Create</button>
    </Modal>
  )
}

// ---------------------------------------------------------------------------
// Forms
// ---------------------------------------------------------------------------

function Forms() {
  const state = useAsync(() => api.get('/admin/forms'), [])
  const years = useAsync(() => api.get('/admin/academic-years'), [])
  const [show, setShow] = useState(false)

  return (
    <div>
      <Header title="Forms" onAdd={() => setShow(true)} />
      {state.loading ? <Spinner /> : state.error ? <ErrorBox msg={state.error} /> : (
        <Table>
          {state.data.map((f) => (
            <tr key={f.id}>
              <td>{f.name}</td>
              <td>Level {f.level ?? '—'}</td>
              <td>{f.class_count} classes</td>
              <td><button className="danger" onClick={() => remove(`/admin/forms/${f.id}`, state.reload)}>Delete</button></td>
            </tr>
          ))}
        </Table>
      )}
      {show && <FormForm years={years.data || []} onDone={() => { setShow(false); state.reload() }} />}
    </div>
  )
}

function FormForm({ years, onDone }) {
  const [academic_year_id, setAy] = useState(years[0]?.id || '')
  const [name, setName] = useState('')
  const [level, setLevel] = useState('')
  const [error, setError] = useState(null)

  async function save() {
    try {
      await api.post('/admin/forms', { academic_year_id: Number(academic_year_id), name, level: level ? Number(level) : null })
      onDone()
    } catch (e) {
      setError(e.message)
    }
  }

  return (
    <Modal title="New form" onClose={onDone}>
      <Field label="Academic year">
        <select value={academic_year_id} onChange={(e) => setAy(e.target.value)}>
          {years.map((y) => <option key={y.id} value={y.id}>{y.name}</option>)}
        </select>
      </Field>
      <Field label="Name (e.g. Primary 5)"><input value={name} onChange={(e) => setName(e.target.value)} /></Field>
      <Field label="Level (1-6)"><input type="number" value={level} onChange={(e) => setLevel(e.target.value)} /></Field>
      {error && <ErrorBox msg={error} />}
      <button className="primary" onClick={save}>Create</button>
    </Modal>
  )
}

// ---------------------------------------------------------------------------
// Classes
// ---------------------------------------------------------------------------

function Classes() {
  const state = useAsync(() => api.get('/admin/classes'), [])
  const forms = useAsync(() => api.get('/admin/forms'), [])
  const [show, setShow] = useState(false)
  const [bulk, setBulk] = useState(false)

  return (
    <div>
      <Header title="Classes" onAdd={() => setShow(true)} extra={<button className="ghost" onClick={() => setBulk(true)}>Bulk create</button>} />
      {state.loading ? <Spinner /> : state.error ? <ErrorBox msg={state.error} /> : (
        <Table>
          {state.data.map((c) => (
            <tr key={c.id}>
              <td>{c.name}</td>
              <td>{formName(forms.data || [], c.form_id)}</td>
              <td>{c.student_count} students</td>
              <td><button className="danger" onClick={() => remove(`/admin/classes/${c.id}`, state.reload)}>Delete</button></td>
            </tr>
          ))}
        </Table>
      )}
      {show && <ClassForm forms={forms.data || []} onDone={() => { setShow(false); state.reload() }} />}
      {bulk && <BulkClassForm forms={forms.data || []} onDone={() => { setBulk(false); state.reload() }} />}
    </div>
  )
}

function ClassForm({ forms, onDone }) {
  const [form_id, setForm] = useState(forms[0]?.id || '')
  const [name, setName] = useState('')
  const [error, setError] = useState(null)

  async function save() {
    try {
      await api.post('/admin/classes', { form_id: Number(form_id), name })
      onDone()
    } catch (e) {
      setError(e.message)
    }
  }

  return (
    <Modal title="New class" onClose={onDone}>
      <Field label="Form">
        <select value={form_id} onChange={(e) => setForm(e.target.value)}>
          {forms.map((f) => <option key={f.id} value={f.id}>{f.name}</option>)}
        </select>
      </Field>
      <Field label="Name (e.g. 5A)"><input value={name} onChange={(e) => setName(e.target.value)} /></Field>
      {error && <ErrorBox msg={error} />}
      <button className="primary" onClick={save}>Create</button>
    </Modal>
  )
}

function BulkClassForm({ forms, onDone }) {
  const [form_id, setForm] = useState(forms[0]?.id || '')
  const [names, setNames] = useState('')
  const [error, setError] = useState(null)

  async function save() {
    try {
      const list = names.split(',').map((s) => s.trim()).filter(Boolean)
      await api.post('/admin/classes/bulk', { form_id: Number(form_id), names: list })
      onDone()
    } catch (e) {
      setError(e.message)
    }
  }

  return (
    <Modal title="Bulk create classes" onClose={onDone}>
      <Field label="Form">
        <select value={form_id} onChange={(e) => setForm(e.target.value)}>
          {forms.map((f) => <option key={f.id} value={f.id}>{f.name}</option>)}
        </select>
      </Field>
      <Field label="Class names (comma separated, e.g. 5A, 5B, 5C)">
        <input value={names} onChange={(e) => setNames(e.target.value)} placeholder="5A, 5B, 5C" />
      </Field>
      {error && <ErrorBox msg={error} />}
      <button className="primary" onClick={save}>Create</button>
    </Modal>
  )
}

// ---------------------------------------------------------------------------
// Students
// ---------------------------------------------------------------------------

function Students() {
  const classes = useAsync(() => api.get('/admin/classes'), [])
  const [q, setQ] = useState('')
  const [classId, setClassId] = useState('')
  const [rows, setRows] = useState([])
  const [loading, setLoading] = useState(true)
  const [selected, setSelected] = useState({})
  const [show, setShow] = useState(false)
  const [editing, setEditing] = useState(null)
  const [importing, setImporting] = useState(false)

  async function load() {
    setLoading(true)
    try {
      const params = new URLSearchParams()
      if (q) params.set('q', q)
      if (classId) params.set('classroom_id', classId)
      const data = await api.get('/admin/students?' + params.toString())
      setRows(data)
    } finally {
      setLoading(false)
    }
  }

  useEffect(() => {
    load()
  }, [q, classId])

  function toggle(id) {
    setSelected((s) => ({ ...s, [id]: !s[id] }))
  }

  const selectedIds = Object.keys(selected).filter((k) => selected[k]).map(Number)

  async function batchDelete() {
    if (!selectedIds.length) return
    if (!confirm(`Delete ${selectedIds.length} student(s)?`)) return
    await api.post('/admin/students/batch-delete', { ids: selectedIds })
    setSelected({})
    load()
  }

  return (
    <div>
      <Header
        title="Students"
        onAdd={() => { setEditing(null); setShow(true) }}
        extra={<button className="ghost" onClick={() => setImporting(true)}>Import CSV</button>}
      />
      <div className="toolbar">
        <input placeholder="Search name / username / number" value={q} onChange={(e) => setQ(e.target.value)} />
        <select value={classId} onChange={(e) => setClassId(e.target.value)}>
          <option value="">All classes</option>
          {(classes.data || []).map((c) => <option key={c.id} value={c.id}>{c.name}</option>)}
        </select>
        {selectedIds.length > 0 && <button className="danger" onClick={batchDelete}>Delete {selectedIds.length} selected</button>}
      </div>

      {loading ? <Spinner /> : (
        <Table>
          {rows.map((s) => (
            <tr key={s.id} className={s.status === 'disabled' ? 'dim' : ''}>
              <td><input type="checkbox" checked={!!selected[s.id]} onChange={() => toggle(s.id)} /></td>
              <td>{s.english_name} {s.chinese_name && <span className="muted">{s.chinese_name}</span>}</td>
              <td>{s.username}</td>
              <td>{className(classes.data || [], s.classroom_id)}</td>
              <td>{s.student_number || '—'}</td>
              <td>
                <button className="link" onClick={() => { setEditing(s); setShow(true) }}>Edit</button>
                <button className="link" onClick={async () => { await api.post(`/admin/students/${s.id}/toggle-status`); load() }}>
                  {s.status === 'active' ? 'Disable' : 'Enable'}
                </button>
                <button className="link danger-text" onClick={() => remove(`/admin/students/${s.id}`, load)}>Delete</button>
              </td>
            </tr>
          ))}
        </Table>
      )}

      {show && <StudentForm student={editing} classes={classes.data || []} onDone={() => { setShow(false); load() }} />}
      {importing && <ImportStudents classes={classes.data || []} onDone={() => { setImporting(false); load() }} />}
    </div>
  )
}

function StudentForm({ student, classes, onDone }) {
  const [form, setForm] = useState({
    english_name: student?.english_name || '',
    chinese_name: student?.chinese_name || '',
    gender: student?.gender || '',
    date_of_birth: student?.date_of_birth || '',
    guardian_name: student?.guardian_name || '',
    guardian_phone: student?.guardian_phone || '',
    guardian_email: student?.guardian_email || '',
    username: student?.username || '',
    password: '',
    student_number: student?.student_number || '',
    classroom_id: student?.classroom_id || '',
  })
  const [error, setError] = useState(null)

  function set(k, v) {
    setForm((f) => ({ ...f, [k]: v }))
  }

  async function save() {
    try {
      const body = { ...form, classroom_id: form.classroom_id ? Number(form.classroom_id) : null }
      if (!student) {
        if (!body.password) throw new Error('Password is required')
        await api.post('/admin/students', body)
      } else {
        const update = { ...body }
        if (!update.password) delete update.password
        await api.put(`/admin/students/${student.id}`, update)
      }
      onDone()
    } catch (e) {
      setError(e.message)
    }
  }

  return (
    <Modal title={student ? 'Edit student' : 'New student'} onClose={onDone}>
      <div className="grid-2">
        <Field label="English name *"><input value={form.english_name} onChange={(e) => set('english_name', e.target.value)} /></Field>
        <Field label="Chinese name"><input value={form.chinese_name} onChange={(e) => set('chinese_name', e.target.value)} /></Field>
        <Field label="Gender">
          <select value={form.gender} onChange={(e) => set('gender', e.target.value)}>
            <option value="">—</option><option value="M">Male</option><option value="F">Female</option>
          </select>
        </Field>
        <Field label="Date of birth"><input type="date" value={form.date_of_birth} onChange={(e) => set('date_of_birth', e.target.value)} /></Field>
        <Field label="Class">
          <select value={form.classroom_id} onChange={(e) => set('classroom_id', e.target.value)}>
            <option value="">Unassigned</option>
            {classes.map((c) => <option key={c.id} value={c.id}>{c.name}</option>)}
          </select>
        </Field>
        <Field label="Student number"><input value={form.student_number} onChange={(e) => set('student_number', e.target.value)} /></Field>
        <Field label="Guardian name"><input value={form.guardian_name} onChange={(e) => set('guardian_name', e.target.value)} /></Field>
        <Field label="Guardian phone"><input value={form.guardian_phone} onChange={(e) => set('guardian_phone', e.target.value)} /></Field>
        <Field label="Guardian email"><input value={form.guardian_email} onChange={(e) => set('guardian_email', e.target.value)} /></Field>
        <Field label="Username *"><input value={form.username} onChange={(e) => set('username', e.target.value)} /></Field>
        <Field label={student ? 'New password (blank = unchanged)' : 'Password *'}>
          <input type="text" value={form.password} onChange={(e) => set('password', e.target.value)} />
        </Field>
      </div>
      {error && <ErrorBox msg={error} />}
      <button className="primary" onClick={save}>{student ? 'Save' : 'Create'}</button>
    </Modal>
  )
}

function ImportStudents({ classes, onDone }) {
  const [file, setFile] = useState(null)
  const [classroom_id, setClassroomId] = useState('')
  const [result, setResult] = useState(null)
  const [error, setError] = useState(null)

  async function submit() {
    if (!file) return setError('Choose a CSV file')
    const fd = new FormData()
    fd.append('file', file)
    const path = '/admin/students/import' + (classroom_id ? `?classroom_id=${classroom_id}` : '')
    try {
      setResult(await upload(path, fd))
    } catch (e) {
      setError(e.message)
    }
  }

  return (
    <Modal title="Import students (CSV)" onClose={onDone}>
      <p className="hint">
        CSV with header row. Columns: <code>english_name, chinese_name, gender, date_of_birth,
        guardian_name, guardian_phone, guardian_email, username, password, student_number, class_name</code>.
        Only <code>english_name</code> and <code>username</code> are required.
      </p>
      <Field label="Assign to class (optional)">
        <select value={classroom_id} onChange={(e) => setClassroomId(e.target.value)}>
          <option value="">—</option>
          {classes.map((c) => <option key={c.id} value={c.id}>{c.name}</option>)}
        </select>
      </Field>
      <Field label="CSV file"><input type="file" accept=".csv" onChange={(e) => setFile(e.target.files[0])} /></Field>
      {error && <ErrorBox msg={error} />}
      {result && <div className="success">Created {result.created} student(s){result.errors?.length ? `, ${result.errors.length} error(s)` : ''}</div>}
      <button className="primary" onClick={submit}>Import</button>
    </Modal>
  )
}

// ---------------------------------------------------------------------------
// Textbooks & chapters
// ---------------------------------------------------------------------------

function Textbooks() {
  const state = useAsync(() => api.get('/admin/textbooks'), [])
  const forms = useAsync(() => api.get('/admin/forms'), [])
  const [uploading, setUploading] = useState(false)
  const [openBook, setOpenBook] = useState(null)
  const [editing, setEditing] = useState(null)
  const [assigning, setAssigning] = useState(null)

  return (
    <div>
      <Header title="Textbooks" onAdd={() => setUploading(true)} />
      {state.loading ? <Spinner /> : state.error ? <ErrorBox msg={state.error} /> : (
        <Table>
          {state.data.map((t) => (
            <tr key={t.id}>
              <td>{t.title}</td>
              <td>{t.subject || '—'}</td>
              <td>{t.level || '—'}</td>
              <td>{t.chapter_count} chapters</td>
              <td>
                <button className="link" onClick={() => setOpenBook(t)}>Chapters</button>
                <button className="link danger-text" onClick={() => remove(`/admin/textbooks/${t.id}`, state.reload)}>Delete</button>
              </td>
            </tr>
          ))}
        </Table>
      )}
      {uploading && <UploadBook onDone={() => { setUploading(false); state.reload() }} />}
      {openBook && (
        <Chapters book={openBook} forms={forms.data || []}
          onClose={() => setOpenBook(null)}
          onEdit={setEditing} onAssign={setAssigning} onRefresh={() => { state.reload(); setOpenBook((b) => b && { ...b }) }} />
      )}
      {editing && <ChapterEditor chapter={editing} onDone={() => { setEditing(null) }} />}
      {assigning && <AssignChapter chapter={assigning} forms={forms.data || []} onDone={() => setAssigning(null)} />}
    </div>
  )
}

function UploadBook({ onDone }) {
  const [file, setFile] = useState(null)
  const [title, setTitle] = useState('')
  const [subject, setSubject] = useState('English')
  const [level, setLevel] = useState('Primary 5')
  const [busy, setBusy] = useState(false)
  const [error, setError] = useState(null)

  async function submit() {
    if (!file) return setError('Choose a PDF / TXT / DOCX file')
    setBusy(true)
    setError(null)
    const fd = new FormData()
    fd.append('file', file)
    fd.append('title', title)
    fd.append('subject', subject)
    fd.append('level', level)
    try {
      const data = await upload('/admin/textbooks/upload', fd)
      onDone()
    } catch (e) {
      setError(e.message)
    } finally {
      setBusy(false)
    }
  }

  return (
    <Modal title="Upload textbook (RAG → structured chapters)" onClose={onDone}>
      <p className="hint">
        Upload a PDF, TXT or Word document. The backend extracts the text, splits it into
        chapters and uses an LLM to produce vocabulary, grammar, exercises and a reading passage.
      </p>
      <Field label="Title"><input value={title} onChange={(e) => setTitle(e.target.value)} placeholder="Primary 5 English" /></Field>
      <Field label="Subject"><input value={subject} onChange={(e) => setSubject(e.target.value)} /></Field>
      <Field label="Level"><input value={level} onChange={(e) => setLevel(e.target.value)} /></Field>
      <Field label="File"><input type="file" accept=".pdf,.txt,.md,.docx" onChange={(e) => setFile(e.target.files[0])} /></Field>
      {error && <ErrorBox msg={error} />}
      <button className="primary" onClick={submit} disabled={busy}>{busy ? 'Processing with LLM…' : 'Upload & process'}</button>
    </Modal>
  )
}

function Chapters({ book, forms, onClose, onEdit, onAssign, onRefresh }) {
  const [chapters, setChapters] = useState(null)
  const [loading, setLoading] = useState(true)

  async function load() {
    setLoading(true)
    const data = await api.get(`/admin/chapters?textbook_id=${book.id}`)
    setChapters(data)
    setLoading(false)
  }

  useEffect(() => { load() }, [book.id])

  return (
    <Modal title={`Chapters — ${book.title}`} onClose={onClose}>
      {loading ? <Spinner /> : chapters.length === 0 ? <p className="muted">No chapters yet.</p> : (
        chapters.map((c) => (
          <div className="chapter-row" key={c.id}>
            <div>
              <strong>#{c.number} {c.title}</strong>
              <div className="muted small">
                {c.vocabulary?.length || 0} vocab · {c.grammar?.length || 0} grammar · {c.exercises?.length || 0} exercises · {c.reading?.questions?.length || 0} questions
              </div>
            </div>
            <div className="row-actions">
              <button className="link" onClick={() => onEdit(c)}>Edit</button>
              <button className="link" onClick={() => onAssign(c)}>Assign to forms</button>
              <button className="link danger-text" onClick={async () => { await remove(`/admin/chapters/${c.id}`, load) }}>Delete</button>
            </div>
          </div>
        ))
      )}
    </Modal>
  )
}

function ChapterEditor({ chapter, onDone }) {
  const [title, setTitle] = useState(chapter.title)
  const [subtitle, setSubtitle] = useState(chapter.subtitle || '')
  const [json, setJson] = useState(JSON.stringify({ vocabulary: chapter.vocabulary, grammar: chapter.grammar, exercises: chapter.exercises, reading: chapter.reading }, null, 2))
  const [error, setError] = useState(null)

  async function save() {
    try {
      const content = JSON.parse(json)
      await api.put(`/admin/chapters/${chapter.id}`, { title, subtitle, ...content })
      onDone()
    } catch (e) {
      setError(e.message)
    }
  }

  return (
    <Modal title={`Edit chapter — ${chapter.title}`} onClose={onDone}>
      <Field label="Title"><input value={title} onChange={(e) => setTitle(e.target.value)} /></Field>
      <Field label="Subtitle"><input value={subtitle} onChange={(e) => setSubtitle(e.target.value)} /></Field>
      <Field label="Content (JSON)">
        <textarea className="json" value={json} onChange={(e) => setJson(e.target.value)} rows={18} />
      </Field>
      {error && <ErrorBox msg={error} />}
      <button className="primary" onClick={save}>Save</button>
    </Modal>
  )
}

function AssignChapter({ chapter, forms, onDone }) {
  const [selected, setSelected] = useState(chapter.assigned_form_ids || [])

  function toggle(id) {
    setSelected((s) => s.includes(id) ? s.filter((x) => x !== id) : [...s, id])
  }

  async function save() {
    await api.post(`/admin/chapters/${chapter.id}/assign`, { form_ids: selected })
    onDone()
  }

  return (
    <Modal title={`Assign "${chapter.title}" to forms`} onClose={onDone}>
      {forms.length === 0 ? <p className="muted">No forms yet. Create a form first.</p> : forms.map((f) => (
        <label className="check" key={f.id}>
          <input type="checkbox" checked={selected.includes(f.id)} onChange={() => toggle(f.id)} />
          {f.name}
        </label>
      ))}
      <button className="primary" onClick={save}>Save assignment</button>
    </Modal>
  )
}

// ---------------------------------------------------------------------------
// Announcements & homework
// ---------------------------------------------------------------------------

function Announcements() {
  const state = useAsync(() => api.get('/admin/announcements'), [])
  const [show, setShow] = useState(false)
  const [title, setTitle] = useState('')
  const [body, setBody] = useState('')
  const [author, setAuthor] = useState('')

  async function save() {
    await api.post('/admin/announcements', { title, body, author })
    setShow(false); setTitle(''); setBody(''); setAuthor('')
    state.reload()
  }

  return (
    <div>
      <Header title="Announcements" onAdd={() => setShow(true)} />
      {state.loading ? <Spinner /> : (
        <div className="list">
          {state.data.map((a) => (
            <div className="list-item" key={a.id}>
              <div>
                <strong>{a.title}</strong>
                <div className="muted small">{a.body}</div>
                <div className="muted small">— {a.author || 'Admin'} · {fmtDate(a.created_at?.slice(0, 10))}</div>
              </div>
              <button className="link danger-text" onClick={() => remove(`/admin/announcements/${a.id}`, state.reload)}>Delete</button>
            </div>
          ))}
        </div>
      )}
      {show && (
        <Modal title="New announcement" onClose={() => setShow(false)}>
          <Field label="Title"><input value={title} onChange={(e) => setTitle(e.target.value)} /></Field>
          <Field label="Body"><textarea value={body} onChange={(e) => setBody(e.target.value)} rows={4} /></Field>
          <Field label="Author"><input value={author} onChange={(e) => setAuthor(e.target.value)} /></Field>
          <button className="primary" onClick={save}>Post</button>
        </Modal>
      )}
    </div>
  )
}

function Homework() {
  const state = useAsync(() => api.get('/admin/homework'), [])
  const classes = useAsync(() => api.get('/admin/classes'), [])
  const [show, setShow] = useState(false)
  const [title, setTitle] = useState('')
  const [classroom_id, setClassroomId] = useState('')
  const [due_date, setDueDate] = useState('')

  async function save() {
    await api.post('/admin/homework', { title, classroom_id: classroom_id ? Number(classroom_id) : null, due_date: due_date || null })
    setShow(false); setTitle(''); setClassroomId(''); setDueDate('')
    state.reload()
  }

  return (
    <div>
      <Header title="Homework" onAdd={() => setShow(true)} />
      {state.loading ? <Spinner /> : (
        <div className="list">
          {state.data.map((h) => (
            <div className="list-item" key={h.id}>
              <div>
                <strong>{h.title}</strong>
                <div className="muted small">Due {fmtDate(h.due_date)} · {className(classes.data || [], h.classroom_id)}</div>
              </div>
              <button className="link danger-text" onClick={() => remove(`/admin/homework/${h.id}`, state.reload)}>Delete</button>
            </div>
          ))}
        </div>
      )}
      {show && (
        <Modal title="New homework" onClose={() => setShow(false)}>
          <Field label="Title"><input value={title} onChange={(e) => setTitle(e.target.value)} /></Field>
          <Field label="Class">
            <select value={classroom_id} onChange={(e) => setClassroomId(e.target.value)}>
              <option value="">All classes</option>
              {(classes.data || []).map((c) => <option key={c.id} value={c.id}>{c.name}</option>)}
            </select>
          </Field>
          <Field label="Due date"><input type="date" value={due_date} onChange={(e) => setDueDate(e.target.value)} /></Field>
          <button className="primary" onClick={save}>Create</button>
        </Modal>
      )}
    </div>
  )
}

// ---------------------------------------------------------------------------
// Small helpers / shared pieces
// ---------------------------------------------------------------------------

function Header({ title, onAdd, extra }) {
  return (
    <div className="page-head">
      <h1>{title}</h1>
      <div className="head-actions">
        {extra}
        <button className="primary" onClick={onAdd}>+ Add</button>
      </div>
    </div>
  )
}

function Table({ children }) {
  return (
    <div className="table-wrap">
      <table>{children}</table>
    </div>
  )
}

async function remove(path, reload) {
  if (!confirm('Delete this item?')) return
  await api.del(path)
  reload()
}

function formName(forms, id) {
  const f = forms.find((x) => x.id === id)
  return f ? f.name : '—'
}

function className(classes, id) {
  const c = classes.find((x) => x.id === id)
  return c ? c.name : '—'
}

// ---------------------------------------------------------------------------
// App shell
// ---------------------------------------------------------------------------

const NAV = [
  ['dashboard', 'Dashboard'],
  ['years', 'Academic Years'],
  ['forms', 'Forms'],
  ['classes', 'Classes'],
  ['students', 'Students'],
  ['textbooks', 'Textbooks'],
  ['announcements', 'Announcements'],
  ['homework', 'Homework'],
]

export default function App() {
  const [authed, setAuthed] = useState(!!getToken())
  const [view, setView] = useState('dashboard')

  if (!authed) {
    return <Login onLogin={() => setAuthed(true)} />
  }

  function logout() {
    clearToken()
    setAuthed(false)
  }

  return (
    <div className="shell">
      <aside className="sidebar">
        <div className="brand">📚 EL Portal</div>
        <nav>
          {NAV.map(([key, label]) => (
            <button key={key} className={view === key ? 'active' : ''} onClick={() => setView(key)}>{label}</button>
          ))}
        </nav>
        <button className="logout" onClick={logout}>Logout</button>
      </aside>
      <main className="content">
        {view === 'dashboard' && <Dashboard />}
        {view === 'years' && <AcademicYears />}
        {view === 'forms' && <Forms />}
        {view === 'classes' && <Classes />}
        {view === 'students' && <Students />}
        {view === 'textbooks' && <Textbooks />}
        {view === 'announcements' && <Announcements />}
        {view === 'homework' && <Homework />}
      </main>
    </div>
  )
}
