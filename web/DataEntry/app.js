(() => {
  'use strict';

  const CREDENTIALS = {
    username: 'Rebun@Ferga',
    password: 'Rebun@Ferga',
  };

  const DEFAULT_API_URL = 'https://api.npoint.io/84b19991c621186ebc56';
  const STORAGE_KEY_API = 'reboon_cms_api_url';
  const STORAGE_KEY_AUTH = 'reboon_cms_auth_ok';
  const STORAGE_KEY_CACHE = 'reboon_cms_last_data';

  let apiUrl = localStorage.getItem(STORAGE_KEY_API) || DEFAULT_API_URL;
  let db = null;
  let activeSection = 'overview';
  let searchTerm = '';
  let activeQuizScience = 'aqeedah';
  let isSaving = false;
  let modalOnSave = null;

  const SECTIONS = [
    { id: 'overview', group: 'main', icon: '📊', label: 'پوختە و ئامار' },
    { id: 'settings', group: 'main', icon: '⚙️', label: 'ڕێکخستنی Mock API و باکئەپ' },

    { id: 'dailyLearning', group: 'home', icon: '☀️', label: 'فێربوونی ڕۆژانە' },
    { id: 'sciences', group: 'home', icon: '🕌', label: 'زانستەکان' },
    { id: 'courses', group: 'home', icon: '🎬', label: 'ڕاڤەی پەرتووک و کۆرسەکان' },
    { id: 'webinars', group: 'home', icon: '🎙️', label: 'وێبینارەکان' },
    { id: 'pdfBooks', group: 'home', icon: '📚', label: 'کتێبخانەی PDF' },
    { id: 'guidance', group: 'home', icon: '🧭', label: 'ڕێنماییەکان' },
    { id: 'articles', group: 'home', icon: '✍️', label: 'بابەتی نووسراو' },
    { id: 'teachers', group: 'home', icon: '👨‍🏫', label: 'مامۆستایانی فێرگە' },

    { id: 'generalLevels', group: 'academy', icon: '🎓', label: 'مەنهەجی گشتی (ئاستەکان)' },
    { id: 'specializedSciences', group: 'academy', icon: '🔬', label: 'مەنهەجی پسپۆڕی' },
    { id: 'sanad', group: 'academy', icon: '📜', label: 'سەنەدەکان' },
    { id: 'quizzes', group: 'academy', icon: '📝', label: 'تاقیکردنەوە و خۆهەڵسەنگاندن' },

    { id: 'resources', group: 'more', icon: '🌐', label: 'سەرچاوە بەسوودەکان' },
    { id: 'projects', group: 'more', icon: '⭐', label: 'پڕۆژەکانی دیکەی ڕێبوون' },
    { id: 'notifications', group: 'more', icon: '🔔', label: 'ئاگادارکردنەوەکان' },
    { id: 'organization', group: 'more', icon: '🏛️', label: 'ناساندنی ڕێکخراو و ئامانجەکان' },
  ];

  const PDF_CATEGORIES = [
    { value: 'aqeedah', label: 'بیروباوەڕ (العقيدة)' },
    { value: 'fiqh', label: 'فیقهـ (الفقه)' },
    { value: 'hadith', label: 'فەرموودە (الحديث)' },
    { value: 'tafseer', label: 'تەفسیر (التفسير)' },
    { value: 'nahw', label: 'نەحو و عەرەبی (النحو)' },
    { value: 'seerah', label: 'سیرە و مێژوو (السيرة)' },
    { value: 'other', label: 'گشتی' },
  ];

  const RESOURCE_CATEGORIES = [
    { value: 'libraries', label: 'کتێبخانەی دیجیتاڵی' },
    { value: 'apps', label: 'ئەپ و بەرنامە' },
    { value: 'academies', label: 'ئەکادیمیا و پلاتفۆرم' },
    { value: 'websites', label: 'ماڵپەڕی زانستی' },
  ];

  const QUIZ_LABELS = {
    aqeedah: 'بیروباوەڕ (العقيدة)',
    fiqh: 'فیقهـ (الفقه)',
    hadith: 'زانستی فەرموودە (الحديث)',
    tafseer: 'تەفسیر (التفسير)',
    nahw: 'نەحو و ڕێزمان (النحو)',
    seerah: 'سیرەی پێغەمبەر ﷺ',
    usul_fiqh: 'ئوسوڵی فیقهـ',
    history: 'مێژووی ئیسلامی',
    tazkiyah: 'تەزکییە و ئاداب',
    logic: 'مەنتق (المنطق)',
    balagha: 'بەلاغە (البلاغة)',
    terms: 'زاراوەناسی شەرعی',
    sarf: 'صەرف (الصرف)',
  };

  // ===== UTILITIES =====
  const $ = (id) => document.getElementById(id);

  function esc(str) {
    return String(str ?? '')
      .replace(/&/g, '&amp;')
      .replace(/</g, '&lt;')
      .replace(/>/g, '&gt;')
      .replace(/"/g, '&quot;')
      .replace(/'/g, '&#39;');
  }

  function showToast(msg, type = 'success') {
    const container = $('toast-container');
    const el = document.createElement('div');
    el.className = `toast ${type}`;
    el.textContent = msg;
    container.appendChild(el);
    setTimeout(() => el.remove(), 3400);
  }

  function setSyncPill(state, text) {
    const pill = $('sync-status-pill');
    if (!pill) return;
    pill.className = 'sync-pill' + (state === 'syncing' ? ' syncing' : state === 'error' ? ' error' : '');
    pill.textContent = text;
  }

  function countForSection(id) {
    if (!db) return '';
    if (id === 'overview' || id === 'settings') return '';
    if (id === 'organization') return (db.organization?.academyGoals?.length || 0);
    if (id === 'quizzes') {
      const q = db.quizzes || {};
      return Object.values(q).reduce((sum, arr) => sum + (Array.isArray(arr) ? arr.length : 0), 0);
    }
    return Array.isArray(db[id]) ? db[id].length : 0;
  }

  function ensureSchema(raw) {
    const d = raw && typeof raw === 'object' ? raw : {};
    return {
      schemaVersion: 1,
      updatedAt: d.updatedAt || new Date().toISOString(),
      dailyLearning: Array.isArray(d.dailyLearning) ? d.dailyLearning : [],
      sciences: Array.isArray(d.sciences) ? d.sciences : [],
      courses: Array.isArray(d.courses) ? d.courses : [],
      webinars: Array.isArray(d.webinars) ? d.webinars : [],
      pdfBooks: Array.isArray(d.pdfBooks) ? d.pdfBooks : [],
      guidance: Array.isArray(d.guidance) ? d.guidance : [],
      articles: Array.isArray(d.articles) ? d.articles : [],
      teachers: Array.isArray(d.teachers) ? d.teachers : [],
      sanad: Array.isArray(d.sanad) ? d.sanad : [],
      generalLevels: Array.isArray(d.generalLevels) ? d.generalLevels : [],
      specializedSciences: Array.isArray(d.specializedSciences) ? d.specializedSciences : [],
      resources: Array.isArray(d.resources) ? d.resources : [],
      projects: Array.isArray(d.projects) ? d.projects : [],
      quizzes: d.quizzes && typeof d.quizzes === 'object' ? d.quizzes : {},
      notifications: Array.isArray(d.notifications) ? d.notifications : [],
      organization: d.organization && typeof d.organization === 'object'
        ? d.organization
        : {
            orgNameKu: 'ڕێکخراوی ڕێبوون',
            orgSubtitleKu: 'بۆ پەروەردە و ڕاهێنان',
            orgNameAr: 'منظمة ريبون للتربية والتدريب',
            orgNameEn: 'Reboon Organization for Education and Training',
            slogan: '',
            definition: '',
            workAreas: [],
            academyGoals: [],
          },
    };
  }

  // ===== CLOUD MOCK API SYNC =====
  async function loadDefaultDataset() {
    const resp = await fetch('./default_data.json?t=' + Date.now());
    if (!resp.ok) throw new Error('default_data.json unavailable');
    return ensureSchema(await resp.json());
  }

  async function loadFromCloud(showNotification = false) {
    setSyncPill('syncing', '⏳ خەریکە داتاکان دەهێنرێن...');
    try {
      const sep = apiUrl.includes('?') ? '&' : '?';
      const resp = await fetch(`${apiUrl}${sep}t=${Date.now()}`, {
        headers: { Accept: 'application/json' },
      });
      if (!resp.ok) throw new Error('HTTP ' + resp.status);
      const data = await resp.json();

      if (!data || data.initialized === false || !Array.isArray(data.courses)) {
        // Seed cloud automatically from default_data.json if empty
        db = await loadDefaultDataset();
        await saveToCloud('داتا بنەڕەتییەکان بە سەرکەوتوویی بارکرانە سەر Mock API ✓');
      } else {
        db = ensureSchema(data);
        localStorage.setItem(STORAGE_KEY_CACHE, JSON.stringify(db));
        setSyncPill('ok', '✓ پەیوەستە بە Mock API');
        if (showNotification) showToast('داتاکان لە کلاودەوە نوێکرانەوە ✓', 'success');
      }
    } catch (err) {
      console.error('Cloud load failed:', err);
      const cached = localStorage.getItem(STORAGE_KEY_CACHE);
      if (cached) {
        db = ensureSchema(JSON.parse(cached));
      } else {
        try {
          db = await loadDefaultDataset();
        } catch (_) {
          db = ensureSchema({});
        }
      }
      setSyncPill('error', '⚠️ کێشەی پەیوەندی بە Mock API');
      showToast('نەتوانرا لە کلاودەوە بخوێنرێتەوە — داتای کاتی پیشاندرا', 'error');
    }
    renderNav();
    renderMain();
  }

  async function saveToCloud(successMessage = 'گۆڕانکارییەکە پاشەکەوتکرا و ڕاستەوخۆ لە ئەپەکەدا چالاک بوو ✓') {
    if (isSaving) return false;
    isSaving = true;
    db.updatedAt = new Date().toISOString();
    setSyncPill('syncing', '⏳ خەریکە پاشەکەوت دەکرێت لە کلاود...');
    try {
      const resp = await fetch(apiUrl, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json; charset=utf-8' },
        body: JSON.stringify(db),
      });
      if (!resp.ok) throw new Error('HTTP ' + resp.status);
      localStorage.setItem(STORAGE_KEY_CACHE, JSON.stringify(db));
      setSyncPill('ok', '✓ پاشەکەوتکرا لە Mock API');
      showToast(successMessage, 'success');
      renderNav();
      renderMain();
      return true;
    } catch (err) {
      console.error('Cloud save failed:', err);
      setSyncPill('error', '✕ پاشەکەوتکردن سەرکەوتوو نەبوو');
      showToast('هەڵە لە پاشەکەوتکردن بۆ Mock API: ' + err.message, 'error');
      return false;
    } finally {
      isSaving = false;
    }
  }

  // ===== AUTH =====
  function showDashboard() {
    $('login-screen').style.display = 'none';
    $('dashboard-app').style.display = 'block';
    renderNav();
    loadFromCloud(false);
  }

  function showLogin() {
    $('dashboard-app').style.display = 'none';
    $('login-screen').style.display = 'flex';
  }

  $('login-form').addEventListener('submit', (e) => {
    e.preventDefault();
    const u = $('login-username').value.trim();
    const p = $('login-password').value.trim();
    if (u === CREDENTIALS.username && p === CREDENTIALS.password) {
      sessionStorage.setItem(STORAGE_KEY_AUTH, '1');
      $('login-error').style.display = 'none';
      showDashboard();
    } else {
      $('login-error').style.display = 'block';
    }
  });

  $('btn-logout').addEventListener('click', () => {
    sessionStorage.removeItem(STORAGE_KEY_AUTH);
    $('login-password').value = '';
    showLogin();
  });

  $('btn-refresh-cloud').addEventListener('click', () => loadFromCloud(true));

  // Mobile Sidebar
  const sidebar = $('sidebar');
  const overlay = $('sidebar-overlay');
  function closeSidebar() {
    sidebar.classList.remove('open');
    overlay.classList.remove('open');
  }
  $('mobile-menu-btn').addEventListener('click', () => {
    sidebar.classList.toggle('open');
    overlay.classList.toggle('open');
  });
  overlay.addEventListener('click', closeSidebar);

  // ===== MODAL HELPERS =====
  function openModal(title, bodyHtml, onSave) {
    $('modal-title').textContent = title;
    $('modal-body').innerHTML = bodyHtml;
    modalOnSave = onSave;
    $('editor-modal').classList.add('open');
  }

  function closeModal() {
    $('editor-modal').classList.remove('open');
    modalOnSave = null;
  }

  $('modal-close-btn').addEventListener('click', closeModal);
  $('modal-cancel-btn').addEventListener('click', closeModal);
  $('editor-modal').addEventListener('click', (e) => {
    if (e.target === $('editor-modal')) closeModal();
  });
  $('modal-save-btn').addEventListener('click', async () => {
    if (!modalOnSave) return;
    const btn = $('modal-save-btn');
    btn.disabled = true;
    try {
      const ok = await modalOnSave();
      if (ok !== false) closeModal();
    } finally {
      btn.disabled = false;
    }
  });

  // ===== NAVIGATION =====
  function renderNav() {
    const groups = { main: $('nav-main'), home: $('nav-home'), academy: $('nav-academy'), more: $('nav-more') };
    Object.values(groups).forEach((ul) => (ul.innerHTML = ''));

    for (const sec of SECTIONS) {
      const li = document.createElement('li');
      li.className = 'nav-item' + (activeSection === sec.id ? ' active' : '');
      const count = countForSection(sec.id);
      li.innerHTML = `
        <span class="nav-label"><span>${sec.icon}</span><span>${esc(sec.label)}</span></span>
        ${count !== '' ? `<span class="nav-badge">${count}</span>` : ''}
      `;
      li.addEventListener('click', () => {
        activeSection = sec.id;
        searchTerm = '';
        closeSidebar();
        renderNav();
        renderMain();
      });
      groups[sec.group].appendChild(li);
    }

    const activeMeta = SECTIONS.find((s) => s.id === activeSection);
    $('current-page-title').textContent = activeMeta ? `${activeMeta.icon} ${activeMeta.label}` : 'داشبۆرد';
  }

  // ===== MAIN RENDER ROUTER =====
  function renderMain() {
    const root = $('main-content');
    if (!db) {
      root.innerHTML = '<div class="empty-state">چاوەڕوانبە، داتاکان دەهێنرێن...</div>';
      return;
    }

    switch (activeSection) {
      case 'overview': return renderOverview(root);
      case 'settings': return renderSettings(root);
      case 'organization': return renderOrganization(root);
      case 'quizzes': return renderQuizzes(root);
      case 'courses': return renderCourses(root);
      case 'sanad': return renderSanad(root);
      case 'generalLevels': return renderGeneralLevels(root);
      case 'specializedSciences': return renderSpecializedSciences(root);
      default: return renderSimpleCollection(root, activeSection);
    }
  }

  // ===== 1. OVERVIEW =====
  function renderOverview(root) {
    const updatedStr = db.updatedAt ? new Date(db.updatedAt).toLocaleString('ar-IQ') : 'ئێستا';
    const statCards = SECTIONS.filter((s) => s.id !== 'overview' && s.id !== 'settings');

    root.innerHTML = `
      <div class="api-banner">
        <div>
          <h2 style="font-size:18px;margin-bottom:4px;">بەخێربێیت بۆ داشبۆردی بەڕێوەبردنی فێرگەی ڕێبوون ✨</h2>
          <div style="font-size:13px;opacity:0.9;">هەر داتایەک لێرە زیاد بکەیت، دەستکاری بکەیت یان بیسڕیتەوە، ڕاستەوخۆ لە ڕێگەی Mock API لەناو ئەپەکەدا دەردەکەوێت!</div>
          <code>${esc(apiUrl)}</code>
        </div>
        <div style="text-align:left;font-size:12px;opacity:0.88;">
          <div>دوایین نوێکردنەوە:</div>
          <strong>${esc(updatedStr)}</strong>
        </div>
      </div>

      <div class="stats-grid">
        ${statCards.map((s) => `
          <div class="stat-card" data-jump="${s.id}">
            <div class="stat-icon">${s.icon}</div>
            <div class="stat-value">${countForSection(s.id)}</div>
            <div class="stat-label">${esc(s.label)}</div>
          </div>
        `).join('')}
      </div>

      <div class="panel">
        <div class="panel-header">
          <h2>⚡ کردارە خێراکان</h2>
        </div>
        <div style="display:flex;gap:10px;flex-wrap:wrap;">
          <button class="btn btn-primary" data-quick="courses">➕ زیادکردنی کۆرس / ڕاڤەی پەرتووک</button>
          <button class="btn btn-primary" data-quick="webinars">➕ زیادکردنی وێبینار</button>
          <button class="btn btn-primary" data-quick="pdfBooks">➕ زیادکردنی کتێبی PDF</button>
          <button class="btn btn-primary" data-quick="articles">➕ زیادکردنی بابەتی نووسراو</button>
          <button class="btn btn-primary" data-quick="teachers">➕ زیادکردنی مامۆستا</button>
          <button class="btn btn-primary" data-quick="notifications">🔔 ناردنی ئاگادارکردنەوە</button>
        </div>
      </div>
    `;

    root.querySelectorAll('[data-jump]').forEach((el) => {
      el.addEventListener('click', () => {
        activeSection = el.dataset.jump;
        renderNav();
        renderMain();
      });
    });

    root.querySelectorAll('[data-quick]').forEach((el) => {
      el.addEventListener('click', () => {
        const target = el.dataset.quick;
        activeSection = target;
        renderNav();
        renderMain();
        setTimeout(() => {
          const addBtn = root.querySelector('[data-action="add"]');
          if (addBtn) addBtn.click();
        }, 30);
      });
    });
  }

  // ===== 2. SETTINGS & BACKUP =====
  function renderSettings(root) {
    root.innerHTML = `
      <div class="panel">
        <div class="panel-header">
          <h2>☁️ پەیوەندی بە Cloud Mock API (بەبێ سێرڤەر و باکئێند)</h2>
        </div>
        <p style="font-size:13.5px;color:var(--muted);margin-bottom:14px;">
          ئەم داشبۆردە ڕاستەوخۆ بەستراوەتەوە بە Cloud Mock API (npoint.io) کە هەموو ئەپەکە و داشبۆردەکە پێکەوە هاوبەش دەکات بەبێ پێویستی بە هیچ سێرڤەرێک.
        </p>
        <div class="form-group">
          <label>بەستەری Mock API (JSON Endpoint URL)</label>
          <input id="cfg-api-url" class="input" dir="ltr" value="${esc(apiUrl)}" />
        </div>
        <div style="display:flex;gap:10px;flex-wrap:wrap;">
          <button class="btn btn-primary" id="btn-save-api">💾 پاشەکەوتکردن و پەیوەستکردن</button>
          <button class="btn btn-outline" id="btn-reset-api">گەڕاندنەوە بۆ لینکی فەرمی ڕێبوون</button>
        </div>
      </div>

      <div class="panel">
        <div class="panel-header">
          <h2>📦 باکئەپ، هاوردەکردن و گەڕاندنەوەی داتا بنەڕەتییەکان</h2>
        </div>
        <div style="display:flex;gap:10px;flex-wrap:wrap;align-items:center;">
          <button class="btn btn-primary" id="btn-export-json">⬇️ دابەزاندنی هەموو داتاکان (JSON)</button>
          <label class="btn btn-outline" style="cursor:pointer;">
            ⬆️ بارکردنی فایلی JSON بۆ کلاود
            <input type="file" id="input-import-json" accept=".json,application/json" style="display:none;" />
          </label>
          <button class="btn btn-danger" id="btn-reset-defaults">♻️ گەڕاندنەوەی هەموو داتاکان بۆ داتای بنەڕەتی ئەپ</button>
        </div>
      </div>
    `;

    $('btn-save-api').addEventListener('click', () => {
      const val = $('cfg-api-url').value.trim();
      if (!val.startsWith('http')) {
        showToast('تکایە URLێکی دروست بنووسە', 'error');
        return;
      }
      apiUrl = val;
      localStorage.setItem(STORAGE_KEY_API, apiUrl);
      loadFromCloud(true);
    });

    $('btn-reset-api').addEventListener('click', () => {
      apiUrl = DEFAULT_API_URL;
      localStorage.setItem(STORAGE_KEY_API, apiUrl);
      $('cfg-api-url').value = apiUrl;
      loadFromCloud(true);
    });

    $('btn-export-json').addEventListener('click', () => {
      const blob = new Blob([JSON.stringify(db, null, 2)], { type: 'application/json;charset=utf-8' });
      const a = document.createElement('a');
      a.href = URL.createObjectURL(blob);
      a.download = `reboon-data-backup-${new Date().toISOString().slice(0, 10)}.json`;
      a.click();
      URL.revokeObjectURL(a.href);
      showToast('فایلی باکئەپ دابەزێنرا ✓');
    });

    $('input-import-json').addEventListener('change', async (e) => {
      const file = e.target.files?.[0];
      if (!file) return;
      try {
        const text = await file.text();
        db = ensureSchema(JSON.parse(text));
        await saveToCloud('فایلی JSON بە سەرکەوتوویی بارکرا و بڵاوکرایەوە ✓');
      } catch (err) {
        showToast('فایلەکە JSONی دروست نییە: ' + err.message, 'error');
      }
    });

    $('btn-reset-defaults').addEventListener('click', async () => {
      if (!confirm('دڵنیایت دەتەوێت هەموو داتاکان بگەڕێنیتەوە بۆ داتای بنەڕەتی ئەپەکە؟')) return;
      try {
        db = await loadDefaultDataset();
        await saveToCloud('هەموو داتاکان گەڕێنرانەوە بۆ داتای بنەڕەتی ئەپ ✓');
      } catch (err) {
        showToast('هەڵە لە گەڕاندنەوەی داتا بنەڕەتییەکان', 'error');
      }
    });
  }

  // ===== SIMPLE COLLECTION SCHEMAS =====
  const SIMPLE_CONFIGS = {
    dailyLearning: {
      title: 'فێربوونی ڕۆژانە',
      addLabel: 'زیادکردنی وتە / فێربوونی ڕۆژانە',
      fields: [
        { name: 'id', label: 'کۆد (ID)', type: 'text', default: () => 'daily_' + Date.now() },
        { name: 'badge', label: 'باج', type: 'text', default: () => 'فێربوونی ڕۆژانە' },
        { name: 'title', label: 'سەردێڕ', type: 'text', required: true, full: true, default: () => 'فێربوونی ڕۆژانە' },
        { name: 'arabicQuote', label: 'دەق / فەرموودە (عەرەبی یان کوردی)', type: 'textarea', required: true, full: true },
        { name: 'kurdishExplanation', label: 'ڕوونکردنەوەی کوردی', type: 'textarea', full: true },
        { name: 'source', label: 'سەرچاوە', type: 'text', full: true },
      ],
      card: (x) => ({
        title: x.title,
        meta: x.source || x.badge,
        desc: `${x.arabicQuote}\n${x.kurdishExplanation || ''}`,
        tags: [x.badge].filter(Boolean),
      }),
    },

    sciences: {
      title: 'زانستەکان (لیستی زانستە سەرەکییەکان)',
      addLabel: 'زیادکردنی زانستی نوێ',
      fields: [
        { name: 'id', label: 'ناسنامە (بۆ نموونە: aqeedah, fiqh, hadith)', type: 'text', required: true, dir: 'ltr' },
        { name: 'arabicName', label: 'ناو بە عەرەبی (لەسەر کارتەکە دەردەکەوێت)', type: 'text', required: true },
        { name: 'kurdishName', label: 'ناو بە کوردی', type: 'text', required: true },
        { name: 'colorHex', label: 'ڕەنگ', type: 'color', default: () => '#15686C' },
      ],
      card: (x) => ({
        title: `${x.arabicName} — ${x.kurdishName}`,
        meta: `ID: ${x.id}`,
        color: x.colorHex,
        tags: [x.id],
      }),
    },

    webinars: {
      title: 'وێبینارەکان',
      addLabel: 'زیادکردنی وێبیناری نوێ',
      fields: [
        { name: 'id', label: 'کۆد (ID)', type: 'text', default: () => 'web_' + Date.now(), dir: 'ltr' },
        { name: 'title', label: 'ناونیشانی وێبینار', type: 'text', required: true },
        { name: 'speaker', label: 'مامۆستا / پێشکەشکار', type: 'text', required: true },
        { name: 'duration', label: 'ماوە (بۆ نموونە: ٤٥:٠٠ خولەک)', type: 'text', default: () => '٤٠:٠٠ خولەک' },
        { name: 'categoryLabel', label: 'پۆلێن', type: 'text', default: () => 'وێبینار' },
        { name: 'colorStartHex', label: 'ڕەنگی سەرەکی', type: 'color', default: () => '#15686C' },
        { name: 'colorEndHex', label: 'ڕەنگی دووەم', type: 'color', default: () => '#0C4346' },
        { name: 'desc', label: 'پوختە و وردەکاری وێبینار', type: 'textarea', full: true },
      ],
      card: (x) => ({
        title: x.title,
        meta: `${x.speaker} • ${x.duration}`,
        desc: x.desc,
        color: x.colorStartHex,
        tags: [x.categoryLabel],
      }),
    },

    pdfBooks: {
      title: 'کتێبخانەی PDF',
      addLabel: 'زیادکردنی کتێبی PDF',
      fields: [
        { name: 'id', label: 'ژمارە (ID)', type: 'number', default: () => Math.max(29, ...db.pdfBooks.map((b) => Number(b.id) || 0)) + 1 },
        { name: 'title', label: 'ناوی کتێب', type: 'text', required: true },
        { name: 'author', label: 'دانەر / نووسەر', type: 'text', required: true },
        { name: 'category', label: 'بەش / پۆلێن', type: 'select', options: PDF_CATEGORIES, default: () => 'aqeedah' },
        { name: 'pages', label: 'ژمارەی لاپەڕە', type: 'number', default: () => 80 },
        { name: 'size', label: 'قەبارە (بۆ نموونە: 3.5 MB)', type: 'text', default: () => '3.5 MB', dir: 'ltr' },
        { name: 'icon', label: 'ئیمۆجی / ئایکۆن', type: 'text', default: () => '📖' },
        { name: 'coverColorHex', label: 'ڕەنگی بەرگ', type: 'color', default: () => '#15686C' },
        { name: 'desc', label: 'ناساندنی کتێب', type: 'textarea', full: true },
      ],
      card: (x) => ({
        title: `${x.icon || '📖'} ${x.title}`,
        meta: `${x.author} • ${x.pages} لاپەڕە • ${x.size}`,
        desc: x.desc,
        color: x.coverColorHex,
        tags: [PDF_CATEGORIES.find((c) => c.value === x.category)?.label || x.category],
      }),
    },

    guidance: {
      title: 'ڕێنماییەکان (تەندروستی و ڕێکخستنی خوێندن)',
      addLabel: 'زیادکردنی ڕێنمایی نوێ',
      fields: [
        { name: 'id', label: 'کۆد (ID)', type: 'text', default: () => 'guid_' + Date.now(), dir: 'ltr' },
        { name: 'title', label: 'سەردێڕی ڕێنمایی', type: 'text', required: true },
        { name: 'specialist', label: 'پسپۆڕ / پزیشک', type: 'text', required: true },
        { name: 'duration', label: 'ماوە', type: 'text', default: () => '١٠:٠٠ خولەک' },
        { name: 'colorHex', label: 'ڕەنگ', type: 'color', default: () => '#15686C' },
        { name: 'summary', label: 'پوختەی ڕێنمایی', type: 'textarea', full: true },
        { name: 'keyTips', label: 'خاڵە گرنگەکان (هەر خاڵێک لە دێڕێکی نوێدا بنووسە)', type: 'lines', full: true },
      ],
      card: (x) => ({
        title: x.title,
        meta: `${x.specialist} • ${x.duration}`,
        desc: x.summary,
        color: x.colorHex,
        tags: [`${(x.keyTips || []).length} خاڵی گرنگ`],
      }),
    },

    articles: {
      title: 'بابەتی نووسراو',
      addLabel: 'زیادکردنی بابەتی نووسراو',
      fields: [
        { name: 'id', label: 'کۆد (ID)', type: 'text', default: () => 'art_' + Date.now(), dir: 'ltr' },
        { name: 'title', label: 'سەردێڕی بابەت', type: 'text', required: true },
        { name: 'author', label: 'نووسەر', type: 'text', default: () => 'فێرگەی ڕێبوون' },
        { name: 'badge', label: 'پۆلێن / باج', type: 'text', default: () => 'وتاری زانستی' },
        { name: 'colorHex', label: 'ڕەنگ', type: 'color', default: () => '#15686C' },
        { name: 'excerpt', label: 'پوختە (کورتە)', type: 'textarea', full: true },
        { name: 'fullContent', label: 'دەقی تەواوی بابەتەکە', type: 'textarea', full: true },
      ],
      card: (x) => ({
        title: x.title,
        meta: x.author,
        desc: x.excerpt || x.fullContent,
        color: x.colorHex,
        tags: [x.badge].filter(Boolean),
      }),
    },

    teachers: {
      title: 'مامۆستایانی فێرگە',
      addLabel: 'زیادکردنی مامۆستای نوێ',
      fields: [
        { name: 'id', label: 'ژمارە (ID)', type: 'number', default: () => Math.max(0, ...db.teachers.map((t) => Number(t.id) || 0)) + 1 },
        { name: 'name', label: 'ناوی مامۆستا', type: 'text', required: true },
        { name: 'title', label: 'نازناو / پسپۆڕیی سەرەکی', type: 'text', required: true },
        { name: 'specialty', label: 'پسپۆڕیی ورد', type: 'text' },
        { name: 'booksCount', label: 'ژمارەی کتێبەکان', type: 'text', default: () => '٣' },
        { name: 'lessonsCount', label: 'ژمارەی وانەکان', type: 'text', default: () => '٤٥' },
        { name: 'studentsCount', label: 'ژمارەی فێرخوازان', type: 'text', default: () => '٢٥٠+' },
        { name: 'colorStartHex', label: 'ڕەنگی ١', type: 'color', default: () => '#15686C' },
        { name: 'colorEndHex', label: 'ڕەنگی ٢', type: 'color', default: () => '#0C4346' },
        { name: 'bio', label: 'ژیاننامە و ناساندن', type: 'textarea', full: true },
        { name: 'books', label: 'کتێبە ڕاڤەکراوەکان (هەر کتێبێک لە دێڕێکی نوێدا)', type: 'lines', full: true },
      ],
      card: (x) => ({
        title: x.name,
        meta: `${x.title} • ${x.specialty || ''}`,
        desc: x.bio,
        color: x.colorStartHex,
        tags: [`📚 ${x.booksCount} کتێب`, `🎬 ${x.lessonsCount} وانە`, `👥 ${x.studentsCount}`],
      }),
    },

    resources: {
      title: 'سەرچاوە بەسوودەکان',
      addLabel: 'زیادکردنی سەرچاوەی نوێ',
      fields: [
        { name: 'id', label: 'ژمارە (ID)', type: 'number', default: () => Math.max(0, ...db.resources.map((r) => Number(r.id) || 0)) + 1 },
        { name: 'title', label: 'ناوی سەرچاوە', type: 'text', required: true },
        { name: 'url', label: 'بەستەر (URL)', type: 'text', required: true, dir: 'ltr' },
        { name: 'category', label: 'پۆلێن', type: 'select', options: RESOURCE_CATEGORIES, default: () => 'libraries' },
        { name: 'badge', label: 'باج', type: 'text', default: () => 'بەسوود' },
        { name: 'icon', label: 'ئایکۆن / ئیمۆجی', type: 'text', default: () => '🌐' },
        { name: 'desc', label: 'ناساندنی سەرچاوە', type: 'textarea', full: true },
      ],
      card: (x) => ({
        title: `${x.icon || '🌐'} ${x.title}`,
        meta: x.url,
        desc: x.desc,
        tags: [x.badge, RESOURCE_CATEGORIES.find((c) => c.value === x.category)?.label || x.category].filter(Boolean),
      }),
    },

    projects: {
      title: 'پڕۆژەکانی دیکەی ڕێبوون',
      addLabel: 'زیادکردنی پڕۆژەی نوێ',
      fields: [
        { name: 'id', label: 'کۆد (ID)', type: 'text', default: () => 'proj_' + Date.now(), dir: 'ltr' },
        { name: 'title', label: 'ناوی پڕۆژە', type: 'text', required: true },
        { name: 'subtitle', label: 'ژێرنووس', type: 'text' },
        { name: 'badge', label: 'باج', type: 'text', default: () => 'پڕۆژەی ڕێبوون' },
        { name: 'icon', label: 'ئایکۆن / ئیمۆجی', type: 'text', default: () => '⭐' },
        { name: 'linkText', label: 'دەقی دوگمە', type: 'text', default: () => 'زانیاری زیاتر' },
        { name: 'url', label: 'بەستەر (URL)', type: 'text', dir: 'ltr' },
        { name: 'accentColorHex', label: 'ڕەنگ', type: 'color', default: () => '#15686C' },
        { name: 'isFeatured', label: 'پڕۆژەی هەڵبژێردراو (Featured)', type: 'checkbox' },
        { name: 'desc', label: 'وردەکاری پڕۆژە', type: 'textarea', full: true },
      ],
      card: (x) => ({
        title: `${x.icon || '⭐'} ${x.title}`,
        meta: x.subtitle || x.url,
        desc: x.desc,
        color: x.accentColorHex,
        tags: [x.badge, x.isFeatured ? '⭐ هەڵبژێردراو' : ''].filter(Boolean),
      }),
    },

    notifications: {
      title: 'ئاگادارکردنەوەکان (Notifications)',
      addLabel: 'ناردنی ئاگادارکردنەوەی نوێ',
      fields: [
        { name: 'id', label: 'ژمارە (ID)', type: 'number', default: () => Math.max(0, ...db.notifications.map((n) => Number(n.id) || 0)) + 1 },
        { name: 'title', label: 'سەردێڕی ئاگادارکردنەوە', type: 'text', required: true },
        { name: 'time', label: 'کات (بۆ نموونە: هەر ئێستا)', type: 'text', default: () => 'هەر ئێستا' },
        { name: 'icon', label: 'ئایکۆن', type: 'text', default: () => '🔔' },
        { name: 'text', label: 'دەقی ئاگادارکردنەوە', type: 'textarea', required: true, full: true },
      ],
      card: (x) => ({
        title: `${x.icon || '🔔'} ${x.title}`,
        meta: x.time,
        desc: x.text,
        tags: [`#${x.id}`],
      }),
    },
  };

  function buildFormFieldsHtml(fields, values = {}) {
    return `<div class="form-grid">${fields.map((f) => {
      const val = values[f.name] !== undefined
        ? values[f.name]
        : (typeof f.default === 'function' ? f.default() : (f.type === 'checkbox' ? false : ''));
      const fullCls = f.full ? 'full' : '';
      const dirAttr = f.dir ? `dir="${f.dir}"` : '';

      if (f.type === 'checkbox') {
        return `
          <div class="form-group ${fullCls}" style="align-self:end;">
            <label class="checkbox-row">
              <input type="checkbox" name="${f.name}" ${val ? 'checked' : ''} />
              <span>${esc(f.label)}</span>
            </label>
          </div>`;
      }
      if (f.type === 'textarea') {
        return `
          <div class="form-group ${fullCls}">
            <label>${esc(f.label)}</label>
            <textarea class="input" name="${f.name}" ${dirAttr}>${esc(val)}</textarea>
          </div>`;
      }
      if (f.type === 'lines') {
        const textVal = Array.isArray(val) ? val.join('\n') : String(val || '');
        return `
          <div class="form-group ${fullCls}">
            <label>${esc(f.label)}</label>
            <textarea class="input" name="${f.name}" rows="4">${esc(textVal)}</textarea>
          </div>`;
      }
      if (f.type === 'select') {
        return `
          <div class="form-group ${fullCls}">
            <label>${esc(f.label)}</label>
            <select class="input" name="${f.name}">
              ${f.options.map((o) => `<option value="${esc(o.value)}" ${val === o.value ? 'selected' : ''}>${esc(o.label)}</option>`).join('')}
            </select>
          </div>`;
      }
      if (f.type === 'color') {
        const hex = /^#[0-9A-Fa-f]{6}$/.test(val) ? val : '#15686C';
        return `
          <div class="form-group ${fullCls}">
            <label>${esc(f.label)}</label>
            <div style="display:flex;gap:8px;align-items:center;">
              <input type="color" name="${f.name}_picker" value="${hex}" style="width:46px;height:40px;border:1px solid var(--border);border-radius:10px;cursor:pointer;" oninput="this.nextElementSibling.value=this.value" />
              <input type="text" class="input" name="${f.name}" value="${esc(hex)}" dir="ltr" oninput="if(/^#[0-9A-Fa-f]{6}$/.test(this.value))this.previousElementSibling.value=this.value" />
            </div>
          </div>`;
      }
      return `
        <div class="form-group ${fullCls}">
          <label>${esc(f.label)}</label>
          <input class="input" type="${f.type === 'number' ? 'number' : 'text'}" name="${f.name}" value="${esc(val)}" ${dirAttr} />
        </div>`;
    }).join('')}</div>`;
  }

  function readFormFields(container, fields) {
    const obj = {};
    for (const f of fields) {
      const el = container.querySelector(`[name="${f.name}"]`);
      if (!el) continue;
      if (f.type === 'checkbox') {
        obj[f.name] = el.checked;
      } else if (f.type === 'number') {
        obj[f.name] = Number(el.value) || 0;
      } else if (f.type === 'lines') {
        obj[f.name] = el.value.split('\n').map((s) => s.trim()).filter(Boolean);
      } else {
        obj[f.name] = el.value.trim();
        if (f.required && !obj[f.name]) {
          showToast(`تکایە خانەی "${f.label}" پڕبکەرەوە`, 'error');
          el.focus();
          return null;
        }
      }
    }
    return obj;
  }

  function renderSimpleCollection(root, key) {
    const cfg = SIMPLE_CONFIGS[key];
    const items = db[key] || [];
    const filtered = items
      .map((item, idx) => ({ item, idx }))
      .filter(({ item }) => !searchTerm || JSON.stringify(item).toLowerCase().includes(searchTerm.toLowerCase()));

    root.innerHTML = `
      <div class="panel">
        <div class="panel-header">
          <h2>${esc(cfg.title)} (${items.length})</h2>
          <button class="btn btn-primary" data-action="add">➕ ${esc(cfg.addLabel)}</button>
        </div>
        <div class="toolbar">
          <input class="input search-box" id="section-search" placeholder="🔍 گەڕان لەناو ئەم بەشەدا..." value="${esc(searchTerm)}" />
        </div>
        ${filtered.length === 0
          ? '<div class="empty-state">هیچ داتایەک نەدۆزرایەوە. کلیک لە دوگمەی زیادکردن بکە!</div>'
          : `<div class="items-grid">
              ${filtered.map(({ item, idx }) => {
                const c = cfg.card(item);
                return `
                  <div class="item-card">
                    <div>
                      <div class="item-top">
                        <div>
                          <div class="item-title">${esc(c.title)}</div>
                          ${c.meta ? `<div class="item-meta">${esc(c.meta)}</div>` : ''}
                        </div>
                        ${c.color ? `<span class="color-dot" style="background:${esc(c.color)}"></span>` : ''}
                      </div>
                      ${c.desc ? `<div class="item-desc" style="margin-top:8px;">${esc(c.desc)}</div>` : ''}
                      ${c.tags?.length ? `<div class="item-tags" style="margin-top:10px;">${c.tags.map((t) => `<span class="tag">${esc(t)}</span>`).join('')}</div>` : ''}
                    </div>
                    <div class="item-actions">
                      <button class="btn btn-outline btn-sm" data-edit="${idx}">✏️ دەستکاری</button>
                      <button class="btn btn-danger btn-sm" data-del="${idx}">🗑️ سڕینەوە</button>
                    </div>
                  </div>`;
              }).join('')}
            </div>`
        }
      </div>
    `;

    $('section-search')?.addEventListener('input', (e) => {
      searchTerm = e.target.value;
      renderSimpleCollection(root, key);
      const inp = $('section-search');
      if (inp) { inp.focus(); inp.setSelectionRange(inp.value.length, inp.value.length); }
    });

    root.querySelector('[data-action="add"]').addEventListener('click', () => {
      openModal(`➕ ${cfg.addLabel}`, buildFormFieldsHtml(cfg.fields, {}), async () => {
        const vals = readFormFields($('modal-body'), cfg.fields);
        if (!vals) return false;
        if (key === 'notifications') {
          db[key].unshift(vals);
        } else {
          db[key].push(vals);
        }
        return await saveToCloud();
      });
    });

    root.querySelectorAll('[data-edit]').forEach((btn) => {
      btn.addEventListener('click', () => {
        const idx = Number(btn.dataset.edit);
        openModal(`✏️ دەستکاریکردن — ${cfg.title}`, buildFormFieldsHtml(cfg.fields, db[key][idx]), async () => {
          const vals = readFormFields($('modal-body'), cfg.fields);
          if (!vals) return false;
          db[key][idx] = vals;
          return await saveToCloud();
        });
      });
    });

    root.querySelectorAll('[data-del]').forEach((btn) => {
      btn.addEventListener('click', async () => {
        const idx = Number(btn.dataset.del);
        if (!confirm('دڵنیایت دەتەوێت ئەم بڕگەیە بسڕیتەوە؟ ڕاستەوخۆ لە ئەپەکەش دەسڕێتەوە!')) return;
        db[key].splice(idx, 1);
        await saveToCloud('بڕگەکە بە سەرکەوتوویی سڕایەوە ✓');
      });
    });
  }

  // ===== 3. COURSES + NESTED EPISODES =====
  function renderCourses(root) {
    const items = db.courses || [];
    const filtered = items
      .map((item, idx) => ({ item, idx }))
      .filter(({ item }) => !searchTerm || JSON.stringify(item).toLowerCase().includes(searchTerm.toLowerCase()));

    root.innerHTML = `
      <div class="panel">
        <div class="panel-header">
          <h2>🎬 ڕاڤەی پەرتووک و کۆرسەکان (${items.length})</h2>
          <button class="btn btn-primary" data-action="add">➕ زیادکردنی کۆرس / ڕاڤەی پەرتووک</button>
        </div>
        <div class="toolbar">
          <input class="input search-box" id="section-search" placeholder="🔍 گەڕان بە ناوی کتێب، مامۆستا یان زانست..." value="${esc(searchTerm)}" />
        </div>
        <div class="items-grid">
          ${filtered.map(({ item, idx }) => `
            <div class="item-card">
              <div>
                <div class="item-top">
                  <div>
                    <div class="item-title">${esc(item.title)}</div>
                    <div class="item-meta">${esc(item.instructor)} • کلیل: ${esc(item.key)}</div>
                  </div>
                  <span class="color-dot" style="background:${esc(item.accentColorHex || '#15686C')}"></span>
                </div>
                <div class="item-desc" style="margin-top:8px;">${esc(item.summary)}</div>
                <div class="item-tags" style="margin-top:10px;">
                  <span class="tag">${esc(item.category)}</span>
                  <span class="tag">🎬 ${(item.episodes || []).length} ئەڵقە</span>
                  ${item.featured ? '<span class="tag gold">⭐ لە پەڕەی سەرەکی</span>' : ''}
                </div>
              </div>
              <div class="item-actions">
                <button class="btn btn-outline btn-sm" data-edit="${idx}">✏️ دەستکاری و ئەڵقەکان</button>
                <button class="btn btn-danger btn-sm" data-del="${idx}">🗑️ سڕینەوە</button>
              </div>
            </div>
          `).join('')}
        </div>
      </div>
    `;

    $('section-search')?.addEventListener('input', (e) => {
      searchTerm = e.target.value;
      renderCourses(root);
      const inp = $('section-search');
      if (inp) { inp.focus(); inp.setSelectionRange(inp.value.length, inp.value.length); }
    });

    const openCourseEditor = (idx) => {
      const isNew = idx === null;
      const cur = isNew
        ? {
            key: '',
            title: '',
            instructor: '',
            category: 'بیروباوەڕ',
            summary: '',
            accentColorHex: '#15686C',
            featured: true,
            episodes: [{ id: 1, title: 'ئەڵقەی ١: پێشەکی و ناساندن', duration: '٢٥ خولەک' }],
          }
        : JSON.parse(JSON.stringify(db.courses[idx]));

      const renderEpisodeRows = () => {
        const listEl = $('episodes-list');
        if (!listEl) return;
        listEl.innerHTML = cur.episodes.map((ep, i) => `
          <div class="sub-item-row">
            <div class="sub-fields">
              <input class="input" data-ep-title="${i}" placeholder="ناونیشانی ئەڵقە" value="${esc(ep.title)}" />
              <input class="input" data-ep-dur="${i}" placeholder="ماوە (٢٥ خولەک)" value="${esc(ep.duration || '٢٥ خولەک')}" />
            </div>
            <button type="button" class="btn btn-danger btn-sm" data-ep-del="${i}">✕</button>
          </div>
        `).join('');

        listEl.querySelectorAll('[data-ep-title]').forEach((inp) => {
          inp.addEventListener('input', () => (cur.episodes[Number(inp.dataset.epTitle)].title = inp.value));
        });
        listEl.querySelectorAll('[data-ep-dur]').forEach((inp) => {
          inp.addEventListener('input', () => (cur.episodes[Number(inp.dataset.epDur)].duration = inp.value));
        });
        listEl.querySelectorAll('[data-ep-del]').forEach((btn) => {
          btn.addEventListener('click', () => {
            cur.episodes.splice(Number(btn.dataset.epDel), 1);
            renderEpisodeRows();
          });
        });
      };

      const html = `
        <div class="form-grid">
          <div class="form-group">
            <label>ناوی کۆرس / کتێب *</label>
            <input class="input" id="c-title" value="${esc(cur.title)}" />
          </div>
          <div class="form-group">
            <label>کلیلی ناسنامە (Key) *</label>
            <input class="input" id="c-key" value="${esc(cur.key)}" placeholder="وەک ناوی کتێبەکە" />
          </div>
          <div class="form-group">
            <label>مامۆستا *</label>
            <input class="input" id="c-instructor" value="${esc(cur.instructor)}" />
          </div>
          <div class="form-group">
            <label>زانست / پۆلێن</label>
            <input class="input" id="c-category" value="${esc(cur.category)}" />
          </div>
          <div class="form-group">
            <label>ڕەنگی کارت</label>
            <input type="color" id="c-color" value="${/^#[0-9A-Fa-f]{6}$/.test(cur.accentColorHex) ? cur.accentColorHex : '#15686C'}" style="width:60px;height:40px;border:1px solid var(--border);border-radius:10px;" />
          </div>
          <div class="form-group" style="align-self:end;">
            <label class="checkbox-row">
              <input type="checkbox" id="c-featured" ${cur.featured ? 'checked' : ''} />
              <span>دەرکەوێت لە «ڕاڤەی پەرتووکی شەرعی» پەڕەی سەرەکی</span>
            </label>
          </div>
          <div class="form-group full">
            <label>پوختەی کۆرس</label>
            <textarea class="input" id="c-summary">${esc(cur.summary)}</textarea>
          </div>
          <div class="form-group full">
            <div class="sub-list-box">
              <div class="sub-list-header">
                <strong>🎬 ئەڵقەکانی کۆرس (${cur.episodes.length})</strong>
                <button type="button" class="btn btn-primary btn-sm" id="btn-add-episode">➕ زیادکردنی ئەڵقە</button>
              </div>
              <div id="episodes-list"></div>
            </div>
          </div>
        </div>
      `;

      openModal(isNew ? '➕ زیادکردنی کۆرس / ڕاڤەی پەرتووک' : `✏️ دەستکاریکردنی کۆرس: ${cur.title}`, html, async () => {
        const title = $('c-title').value.trim();
        const key = $('c-key').value.trim() || title;
        if (!title) { showToast('ناوی کۆرس بنووسە', 'error'); return false; }
        cur.title = title;
        cur.key = key;
        cur.instructor = $('c-instructor').value.trim() || 'ئەکادیمیای ڕێبوون';
        cur.category = $('c-category').value.trim() || 'وانەی شەرعی';
        cur.accentColorHex = $('c-color').value;
        cur.featured = $('c-featured').checked;
        cur.summary = $('c-summary').value.trim();
        cur.episodes = cur.episodes
          .filter((ep) => ep.title.trim())
          .map((ep, i) => ({ id: i + 1, title: ep.title.trim(), duration: ep.duration.trim() || '٢٥ خولەک' }));
        if (cur.episodes.length === 0) cur.episodes = [{ id: 1, title: 'ئەڵقەی ١', duration: '٢٥ خولەک' }];

        if (isNew) db.courses.unshift(cur);
        else db.courses[idx] = cur;
        return await saveToCloud();
      });

      renderEpisodeRows();
      $('btn-add-episode').addEventListener('click', () => {
        cur.episodes.push({ id: cur.episodes.length + 1, title: `ئەڵقەی ${cur.episodes.length + 1}`, duration: '٢٥ خولەک' });
        renderEpisodeRows();
      });
    };

    root.querySelector('[data-action="add"]').addEventListener('click', () => openCourseEditor(null));
    root.querySelectorAll('[data-edit]').forEach((b) => b.addEventListener('click', () => openCourseEditor(Number(b.dataset.edit))));
    root.querySelectorAll('[data-del]').forEach((b) => b.addEventListener('click', async () => {
      if (!confirm('دڵنیایت لە سڕینەوەی ئەم کۆرسە؟')) return;
      db.courses.splice(Number(b.dataset.del), 1);
      await saveToCloud('کۆرسەکە سڕایەوە ✓');
    }));
  }

  // ===== 4. SANAD + CHAIN NODES =====
  function renderSanad(root) {
    const items = db.sanad || [];
    root.innerHTML = `
      <div class="panel">
        <div class="panel-header">
          <h2>📜 سەنەدەکان (${items.length})</h2>
          <button class="btn btn-primary" data-action="add">➕ زیادکردنی سەنەدی نوێ</button>
        </div>
        <div class="items-grid">
          ${items.map((sn, idx) => `
            <div class="item-card">
              <div>
                <div class="item-top">
                  <div>
                    <div class="item-title">${esc(sn.iconEmoji || '📜')} ${esc(sn.title)}</div>
                    <div class="item-meta">${esc(sn.teacherName)} • ${esc(sn.book)}</div>
                  </div>
                  <span class="color-dot" style="background:${esc(sn.colorHex || '#15686C')}"></span>
                </div>
                <div class="item-desc" style="margin-top:8px;">${esc(sn.description)}</div>
                <div class="item-tags" style="margin-top:10px;">
                  <span class="tag">${esc(sn.science)}</span>
                  <span class="tag">⛓️ ${(sn.chain || []).length} زنجیرەی سەنەد</span>
                </div>
              </div>
              <div class="item-actions">
                <button class="btn btn-outline btn-sm" data-edit="${idx}">✏️ دەستکاری و زنجیرە</button>
                <button class="btn btn-danger btn-sm" data-del="${idx}">🗑️ سڕینەوە</button>
              </div>
            </div>
          `).join('')}
        </div>
      </div>
    `;

    const openSanadEditor = (idx) => {
      const isNew = idx === null;
      const cur = isNew
        ? {
            key: 'sanad_' + Date.now(),
            shortTitle: '',
            title: '',
            science: '',
            book: '',
            teacherName: '',
            description: '',
            reqTitle: 'مەرجەکانی وەرگرتنی ئیجازە',
            reqText: '',
            iconEmoji: '📜',
            colorHex: '#15686C',
            chain: [{ name: '', title: '' }],
          }
        : JSON.parse(JSON.stringify(db.sanad[idx]));

      const renderChain = () => {
        const el = $('sanad-chain-list');
        el.innerHTML = cur.chain.map((node, i) => `
          <div class="sub-item-row">
            <div class="sub-fields">
              <input class="input" data-cn-name="${i}" placeholder="ناوی زانا / گێڕەرەوە" value="${esc(node.name)}" />
              <input class="input" data-cn-title="${i}" placeholder="پلە یان سیفەت" value="${esc(node.title)}" />
            </div>
            <button type="button" class="btn btn-danger btn-sm" data-cn-del="${i}">✕</button>
          </div>
        `).join('');
        el.querySelectorAll('[data-cn-name]').forEach((inp) => inp.addEventListener('input', () => (cur.chain[Number(inp.dataset.cnName)].name = inp.value)));
        el.querySelectorAll('[data-cn-title]').forEach((inp) => inp.addEventListener('input', () => (cur.chain[Number(inp.dataset.cnTitle)].title = inp.value)));
        el.querySelectorAll('[data-cn-del]').forEach((b) => b.addEventListener('click', () => { cur.chain.splice(Number(b.dataset.cnDel), 1); renderChain(); }));
      };

      const html = `
        <div class="form-grid">
          <div class="form-group"><label>سەردێڕی تەواو *</label><input class="input" id="sn-title" value="${esc(cur.title)}" /></div>
          <div class="form-group"><label>سەردێڕی کورت</label><input class="input" id="sn-short" value="${esc(cur.shortTitle)}" /></div>
          <div class="form-group"><label>زانست</label><input class="input" id="sn-science" value="${esc(cur.science)}" /></div>
          <div class="form-group"><label>کتێب / مەتن</label><input class="input" id="sn-book" value="${esc(cur.book)}" /></div>
          <div class="form-group"><label>مامۆستای ئیجازەدەر</label><input class="input" id="sn-teacher" value="${esc(cur.teacherName)}" /></div>
          <div class="form-group"><label>ئایکۆن و ڕەنگ</label>
            <div style="display:flex;gap:8px;">
              <input class="input" id="sn-icon" value="${esc(cur.iconEmoji)}" style="width:70px;text-align:center;" />
              <input type="color" id="sn-color" value="${/^#[0-9A-Fa-f]{6}$/.test(cur.colorHex) ? cur.colorHex : '#15686C'}" style="width:52px;height:40px;border-radius:10px;border:1px solid var(--border);" />
            </div>
          </div>
          <div class="form-group full"><label>پێناسەی سەنەد</label><textarea class="input" id="sn-desc">${esc(cur.description)}</textarea></div>
          <div class="form-group"><label>سەردێڕی مەرجەکان</label><input class="input" id="sn-reqt" value="${esc(cur.reqTitle)}" /></div>
          <div class="form-group"><label>کۆد (Key)</label><input class="input" id="sn-key" dir="ltr" value="${esc(cur.key)}" /></div>
          <div class="form-group full"><label>دەقی مەرجەکان</label><textarea class="input" id="sn-req">${esc(cur.reqText)}</textarea></div>
          <div class="form-group full">
            <div class="sub-list-box">
              <div class="sub-list-header">
                <strong>⛓️ زنجیرەی سەنەد (Chain)</strong>
                <button type="button" class="btn btn-primary btn-sm" id="btn-add-chain">➕ زیادکردنی ئەڵقەی زنجیرە</button>
              </div>
              <div id="sanad-chain-list"></div>
            </div>
          </div>
        </div>
      `;

      openModal(isNew ? '➕ زیادکردنی سەنەد' : `✏️ دەستکاریکردنی سەنەد`, html, async () => {
        const title = $('sn-title').value.trim();
        if (!title) { showToast('سەردێڕی سەنەد بنووسە', 'error'); return false; }
        cur.title = title;
        cur.shortTitle = $('sn-short').value.trim() || title;
        cur.science = $('sn-science').value.trim();
        cur.book = $('sn-book').value.trim();
        cur.teacherName = $('sn-teacher').value.trim();
        cur.iconEmoji = $('sn-icon').value.trim() || '📜';
        cur.colorHex = $('sn-color').value;
        cur.description = $('sn-desc').value.trim();
        cur.reqTitle = $('sn-reqt').value.trim();
        cur.reqText = $('sn-req').value.trim();
        cur.key = $('sn-key').value.trim() || ('sanad_' + Date.now());
        cur.chain = cur.chain.filter((n) => n.name.trim());
        if (isNew) db.sanad.push(cur);
        else db.sanad[idx] = cur;
        return await saveToCloud();
      });

      renderChain();
      $('btn-add-chain').addEventListener('click', () => {
        cur.chain.push({ name: '', title: '' });
        renderChain();
      });
    };

    root.querySelector('[data-action="add"]').addEventListener('click', () => openSanadEditor(null));
    root.querySelectorAll('[data-edit]').forEach((b) => b.addEventListener('click', () => openSanadEditor(Number(b.dataset.edit))));
    root.querySelectorAll('[data-del]').forEach((b) => b.addEventListener('click', async () => {
      if (!confirm('دڵنیایت لە سڕینەوەی ئەم سەنەدە؟')) return;
      db.sanad.splice(Number(b.dataset.del), 1);
      await saveToCloud('سەنەدەکە سڕایەوە ✓');
    }));
  }

  // ===== 5. GENERAL LEVELS + NESTED COURSES =====
  function renderGeneralLevels(root) {
    const levels = db.generalLevels || [];
    root.innerHTML = `
      <div class="panel">
        <div class="panel-header">
          <h2>🎓 مەنهەجی گشتی — ئاستەکان (${levels.length})</h2>
          <button class="btn btn-primary" data-action="add">➕ زیادکردنی ئاستی نوێ</button>
        </div>
        <div class="items-grid">
          ${levels.map((lvl, idx) => `
            <div class="item-card">
              <div>
                <div class="item-top">
                  <div>
                    <div class="item-title">${esc(lvl.badgeText)} — ${esc(lvl.title)}</div>
                    <div class="item-meta">ئاستی ژمارە ${lvl.levelNumber} • ${(lvl.courses || []).length} کۆرس</div>
                  </div>
                  <span class="color-dot" style="background:${esc(lvl.badgeColorHex || '#15686C')}"></span>
                </div>
                <div class="item-tags" style="margin-top:10px;">
                  ${(lvl.courses || []).map((c) => `<span class="tag">${esc(c.title)}</span>`).join('')}
                </div>
              </div>
              <div class="item-actions">
                <button class="btn btn-outline btn-sm" data-edit="${idx}">✏️ دەستکاری و وانەکان</button>
                <button class="btn btn-danger btn-sm" data-del="${idx}">🗑️ سڕینەوە</button>
              </div>
            </div>
          `).join('')}
        </div>
      </div>
    `;

    const openLevelEditor = (idx) => {
      const isNew = idx === null;
      const cur = isNew
        ? {
            levelNumber: levels.length + 1,
            badgeText: `ئاستی ${levels.length + 1}`,
            title: '',
            badgeColorHex: '#15686C',
            courses: [],
          }
        : JSON.parse(JSON.stringify(db.generalLevels[idx]));

      const renderLvlCourses = () => {
        const el = $('lvl-courses-list');
        el.innerHTML = cur.courses.map((c, i) => `
          <div class="sub-item-row">
            <div class="sub-fields">
              <input class="input" data-lc="title" data-i="${i}" placeholder="ناونیشانی کۆرس" value="${esc(c.title)}" />
              <input class="input" data-lc="courseKey" data-i="${i}" placeholder="کلیلی کۆرس (Key)" value="${esc(c.courseKey)}" />
              <input class="input" data-lc="scienceBadge" data-i="${i}" placeholder="باجی زانست" value="${esc(c.scienceBadge)}" />
              <input class="input" data-lc="mainBook" data-i="${i}" placeholder="کتێبی سەرەکی" value="${esc(c.mainBook)}" />
              <input class="input" data-lc="supportBook" data-i="${i}" placeholder="کتێبی پاڵپشت" value="${esc(c.supportBook)}" />
              <input class="input" data-lc="instructorFull" data-i="${i}" placeholder="ناوی مامۆستا" value="${esc(c.instructorFull)}" />
            </div>
            <button type="button" class="btn btn-danger btn-sm" data-lc-del="${i}">✕</button>
          </div>
        `).join('');
        el.querySelectorAll('[data-lc]').forEach((inp) => {
          inp.addEventListener('input', () => {
            const i = Number(inp.dataset.i);
            cur.courses[i][inp.dataset.lc] = inp.value;
            if (inp.dataset.lc === 'instructorFull') cur.courses[i].instructorShort = inp.value;
          });
        });
        el.querySelectorAll('[data-lc-del]').forEach((b) => b.addEventListener('click', () => {
          cur.courses.splice(Number(b.dataset.lcDel), 1);
          renderLvlCourses();
        }));
      };

      const html = `
        <div class="form-grid">
          <div class="form-group"><label>ژمارەی ئاست</label><input type="number" class="input" id="gl-num" value="${cur.levelNumber}" /></div>
          <div class="form-group"><label>باجی ئاست</label><input class="input" id="gl-badge" value="${esc(cur.badgeText)}" /></div>
          <div class="form-group"><label>سەردێڕی ئاست *</label><input class="input" id="gl-title" value="${esc(cur.title)}" /></div>
          <div class="form-group"><label>ڕەنگی ئاست</label><input type="color" id="gl-color" value="${/^#[0-9A-Fa-f]{6}$/.test(cur.badgeColorHex) ? cur.badgeColorHex : '#15686C'}" style="width:60px;height:40px;border-radius:10px;border:1px solid var(--border);" /></div>
          <div class="form-group full">
            <div class="sub-list-box">
              <div class="sub-list-header">
                <strong>📚 کۆرسەکانی ئەم ئاستە</strong>
                <button type="button" class="btn btn-primary btn-sm" id="btn-add-lc">➕ زیادکردنی کۆرس بۆ ئاست</button>
              </div>
              <div id="lvl-courses-list"></div>
            </div>
          </div>
        </div>
      `;

      openModal(isNew ? '➕ زیادکردنی ئاستی نوێ' : `✏️ دەستکاریکردنی ${cur.badgeText}`, html, async () => {
        const title = $('gl-title').value.trim();
        if (!title) { showToast('سەردێڕی ئاست بنووسە', 'error'); return false; }
        cur.levelNumber = Number($('gl-num').value) || 1;
        cur.badgeText = $('gl-badge').value.trim() || `ئاستی ${cur.levelNumber}`;
        cur.title = title;
        cur.badgeColorHex = $('gl-color').value;
        cur.courses = cur.courses.filter((c) => c.title.trim()).map((c) => ({
          ...c,
          courseKey: c.courseKey.trim() || c.title.trim(),
          instructorShort: c.instructorShort || c.instructorFull || '',
          colorHex: c.colorHex || cur.badgeColorHex,
        }));
        if (isNew) db.generalLevels.push(cur);
        else db.generalLevels[idx] = cur;
        return await saveToCloud();
      });

      renderLvlCourses();
      $('btn-add-lc').addEventListener('click', () => {
        cur.courses.push({
          courseKey: '',
          scienceBadge: 'وانە',
          title: '',
          mainBook: '',
          supportBook: '',
          instructorShort: '',
          instructorFull: '',
          colorHex: cur.badgeColorHex,
        });
        renderLvlCourses();
      });
    };

    root.querySelector('[data-action="add"]').addEventListener('click', () => openLevelEditor(null));
    root.querySelectorAll('[data-edit]').forEach((b) => b.addEventListener('click', () => openLevelEditor(Number(b.dataset.edit))));
    root.querySelectorAll('[data-del]').forEach((b) => b.addEventListener('click', async () => {
      if (!confirm('دڵنیایت لە سڕینەوەی ئەم ئاستە؟')) return;
      db.generalLevels.splice(Number(b.dataset.del), 1);
      await saveToCloud('ئاستەکە سڕایەوە ✓');
    }));
  }

  // ===== 6. SPECIALIZED SCIENCES + STAGES =====
  function renderSpecializedSciences(root) {
    const items = db.specializedSciences || [];
    root.innerHTML = `
      <div class="panel">
        <div class="panel-header">
          <h2>🔬 مەنهەجی پسپۆڕی (${items.length})</h2>
          <button class="btn btn-primary" data-action="add">➕ زیادکردنی زانستی پسپۆڕی</button>
        </div>
        <div class="items-grid">
          ${items.map((sc, idx) => `
            <div class="item-card">
              <div>
                <div class="item-top">
                  <div>
                    <div class="item-title">${esc(sc.emoji || '📖')} ${esc(sc.title)}</div>
                    <div class="item-meta">${esc(sc.subtitle)}</div>
                  </div>
                  <span class="color-dot" style="background:${esc(sc.colorHex || '#15686C')}"></span>
                </div>
                <div class="item-tags" style="margin-top:10px;">
                  ${(sc.stages || []).map((st) => `<span class="tag">${esc(st.stageLabel)}: ${esc(st.title)}</span>`).join('')}
                </div>
              </div>
              <div class="item-actions">
                <button class="btn btn-outline btn-sm" data-edit="${idx}">✏️ دەستکاری و قۆناغەکان</button>
                <button class="btn btn-danger btn-sm" data-del="${idx}">🗑️ سڕینەوە</button>
              </div>
            </div>
          `).join('')}
        </div>
      </div>
    `;

    const openSpecEditor = (idx) => {
      const isNew = idx === null;
      const cur = isNew
        ? { id: 'spec_' + Date.now(), emoji: '📖', title: '', subtitle: '', colorHex: '#15686C', stages: [] }
        : JSON.parse(JSON.stringify(db.specializedSciences[idx]));

      const renderStages = () => {
        const el = $('spec-stages-list');
        el.innerHTML = cur.stages.map((st, i) => `
          <div class="sub-item-row">
            <div class="sub-fields">
              <input class="input" data-st="stageLabel" data-i="${i}" placeholder="قۆناغ (سەرەتایی / ناوەند / باڵا)" value="${esc(st.stageLabel)}" />
              <input class="input" data-st="title" data-i="${i}" placeholder="ناونیشانی قۆناغ" value="${esc(st.title)}" />
              <input class="input" data-st="courseKey" data-i="${i}" placeholder="کلیلی کۆرس (Key)" value="${esc(st.courseKey)}" />
              <input class="input" data-st="mainBook" data-i="${i}" placeholder="کتێبی سەرەکی" value="${esc(st.mainBook)}" />
              <input class="input" data-st="supportBook" data-i="${i}" placeholder="کتێبی پاڵپشت" value="${esc(st.supportBook)}" />
              <input class="input" data-st="instructorFull" data-i="${i}" placeholder="ناوی مامۆستا" value="${esc(st.instructorFull)}" />
            </div>
            <button type="button" class="btn btn-danger btn-sm" data-st-del="${i}">✕</button>
          </div>
        `).join('');
        el.querySelectorAll('[data-st]').forEach((inp) => inp.addEventListener('input', () => (cur.stages[Number(inp.dataset.i)][inp.dataset.st] = inp.value)));
        el.querySelectorAll('[data-st-del]').forEach((b) => b.addEventListener('click', () => { cur.stages.splice(Number(b.dataset.stDel), 1); renderStages(); }));
      };

      const html = `
        <div class="form-grid">
          <div class="form-group"><label>سەردێڕی زانست *</label><input class="input" id="sp-title" value="${esc(cur.title)}" /></div>
          <div class="form-group"><label>ژێرنووس</label><input class="input" id="sp-sub" value="${esc(cur.subtitle)}" /></div>
          <div class="form-group"><label>کۆد (ID)</label><input class="input" id="sp-id" dir="ltr" value="${esc(cur.id)}" /></div>
          <div class="form-group"><label>ئیمۆجی و ڕەنگ</label>
            <div style="display:flex;gap:8px;">
              <input class="input" id="sp-emoji" value="${esc(cur.emoji)}" style="width:70px;text-align:center;" />
              <input type="color" id="sp-color" value="${/^#[0-9A-Fa-f]{6}$/.test(cur.colorHex) ? cur.colorHex : '#15686C'}" style="width:52px;height:40px;border-radius:10px;border:1px solid var(--border);" />
            </div>
          </div>
          <div class="form-group full">
            <div class="sub-list-box">
              <div class="sub-list-header">
                <strong>🎯 قۆناغەکانی خوێندن</strong>
                <button type="button" class="btn btn-primary btn-sm" id="btn-add-stage">➕ زیادکردنی قۆناغ</button>
              </div>
              <div id="spec-stages-list"></div>
            </div>
          </div>
        </div>
      `;

      openModal(isNew ? '➕ زیادکردنی زانستی پسپۆڕی' : `✏️ دەستکاریکردنی ${cur.title}`, html, async () => {
        const title = $('sp-title').value.trim();
        if (!title) { showToast('سەردێڕی زانست بنووسە', 'error'); return false; }
        cur.title = title;
        cur.subtitle = $('sp-sub').value.trim();
        cur.id = $('sp-id').value.trim() || ('spec_' + Date.now());
        cur.emoji = $('sp-emoji').value.trim() || '📖';
        cur.colorHex = $('sp-color').value;
        cur.stages = cur.stages.filter((st) => st.title.trim()).map((st) => ({
          ...st,
          courseKey: st.courseKey.trim() || st.title.trim(),
        }));
        if (isNew) db.specializedSciences.push(cur);
        else db.specializedSciences[idx] = cur;
        return await saveToCloud();
      });

      renderStages();
      $('btn-add-stage').addEventListener('click', () => {
        cur.stages.push({ courseKey: '', stageLabel: 'قۆناغی نوێ', title: '', mainBook: '', supportBook: '', instructorFull: '' });
        renderStages();
      });
    };

    root.querySelector('[data-action="add"]').addEventListener('click', () => openSpecEditor(null));
    root.querySelectorAll('[data-edit]').forEach((b) => b.addEventListener('click', () => openSpecEditor(Number(b.dataset.edit))));
    root.querySelectorAll('[data-del]').forEach((b) => b.addEventListener('click', async () => {
      if (!confirm('دڵنیایت لە سڕینەوەی ئەم زانستە پسپۆڕییە؟')) return;
      db.specializedSciences.splice(Number(b.dataset.del), 1);
      await saveToCloud('زانستە پسپۆڕییەکە سڕایەوە ✓');
    }));
  }

  // ===== 7. QUIZZES & SELF-ASSESSMENT =====
  function renderQuizzes(root) {
    const keys = Object.keys(db.quizzes || {});
    if (!keys.includes(activeQuizScience) && keys.length > 0) activeQuizScience = keys[0];
    const list = db.quizzes[activeQuizScience] || [];

    root.innerHTML = `
      <div class="panel">
        <div class="panel-header">
          <h2>📝 بانکی پرسیارەکانی تاقیکردنەوە و خۆهەڵسەنگاندن</h2>
          <button class="btn btn-primary" data-action="add">➕ زیادکردنی پرسیاری نوێ</button>
        </div>
        <div class="toolbar">
          <label style="font-weight:700;">زانست هەڵبژێرە:</label>
          <select class="input" id="quiz-science-select" style="max-width:290px;">
            ${keys.map((k) => `<option value="${esc(k)}" ${k === activeQuizScience ? 'selected' : ''}>${esc(QUIZ_LABELS[k] || k)} (${(db.quizzes[k] || []).length})</option>`).join('')}
          </select>
          <button class="btn btn-outline btn-sm" id="btn-add-quiz-cat">➕ بەشی زانستی نوێ</button>
        </div>
        ${list.length === 0
          ? '<div class="empty-state">هیچ پرسیارێک لەم بەشەدا نییە. پرسیارێک زیاد بکە!</div>'
          : `<div class="items-grid">
              ${list.map((q, idx) => `
                <div class="item-card">
                  <div>
                    <div class="item-title">پ${idx + 1}: ${esc(q.question)}</div>
                    <div style="margin-top:8px;font-size:12.5px;">
                      ${(q.options || []).map((opt, oi) => `
                        <div style="padding:4px 8px;border-radius:8px;margin-bottom:4px;background:${oi === q.correctIndex ? 'var(--success-soft)' : '#F7F9F9'};color:${oi === q.correctIndex ? 'var(--success)' : 'var(--text)'};font-weight:${oi === q.correctIndex ? '700' : '400'};">
                          ${oi === q.correctIndex ? '✓ ' : '• '}${esc(opt)}
                        </div>
                      `).join('')}
                    </div>
                    ${q.explanation ? `<div class="item-meta" style="margin-top:6px;">💡 ${esc(q.explanation)}</div>` : ''}
                  </div>
                  <div class="item-actions">
                    <button class="btn btn-outline btn-sm" data-edit="${idx}">✏️ دەستکاری</button>
                    <button class="btn btn-danger btn-sm" data-del="${idx}">🗑️ سڕینەوە</button>
                  </div>
                </div>
              `).join('')}
            </div>`
        }
      </div>
    `;

    $('quiz-science-select').addEventListener('change', (e) => {
      activeQuizScience = e.target.value;
      renderQuizzes(root);
    });

    $('btn-add-quiz-cat').addEventListener('click', () => {
      const code = prompt('کۆدی زانستی نوێ بنووسە بە ئینگلیزی (بۆ نموونە: sarf یان quran):');
      if (!code || !code.trim()) return;
      const clean = code.trim();
      if (!db.quizzes[clean]) db.quizzes[clean] = [];
      activeQuizScience = clean;
      renderQuizzes(root);
    });

    const openQuizEditor = (idx) => {
      const isNew = idx === null;
      const cur = isNew
        ? { question: '', options: ['', '', '', ''], correctIndex: 0, explanation: '' }
        : JSON.parse(JSON.stringify(list[idx]));
      while (cur.options.length < 4) cur.options.push('');

      const html = `
        <div class="form-grid">
          <div class="form-group full"><label>دەقی پرسیار *</label><textarea class="input" id="q-text">${esc(cur.question)}</textarea></div>
          ${[0, 1, 2, 3].map((i) => `
            <div class="form-group">
              <label>بژاردەی ${i + 1}</label>
              <input class="input" id="q-opt-${i}" value="${esc(cur.options[i] || '')}" />
            </div>
          `).join('')}
          <div class="form-group full">
            <label>وەڵامی ڕاست کامەیە؟</label>
            <select class="input" id="q-correct">
              ${[0, 1, 2, 3].map((i) => `<option value="${i}" ${cur.correctIndex === i ? 'selected' : ''}>بژاردەی ${i + 1}</option>`).join('')}
            </select>
          </div>
          <div class="form-group full"><label>ڕوونکردنەوەی وەڵامی ڕاست</label><textarea class="input" id="q-exp">${esc(cur.explanation)}</textarea></div>
        </div>
      `;

      openModal(isNew ? '➕ زیادکردنی پرسیار' : '✏️ دەستکاریکردنی پرسیار', html, async () => {
        const question = $('q-text').value.trim();
        const opts = [0, 1, 2, 3].map((i) => $(`q-opt-${i}`).value.trim()).filter(Boolean);
        if (!question || opts.length < 2) {
          showToast('تکایە پرسیارەکە و بەلایەنی کەم دوو بژاردە بنووسە', 'error');
          return false;
        }
        const correctIndex = Math.min(Number($('q-correct').value) || 0, opts.length - 1);
        const item = { question, options: opts, correctIndex, explanation: $('q-exp').value.trim() };
        if (!db.quizzes[activeQuizScience]) db.quizzes[activeQuizScience] = [];
        if (isNew) db.quizzes[activeQuizScience].push(item);
        else db.quizzes[activeQuizScience][idx] = item;
        return await saveToCloud();
      });
    };

    root.querySelector('[data-action="add"]').addEventListener('click', () => openQuizEditor(null));
    root.querySelectorAll('[data-edit]').forEach((b) => b.addEventListener('click', () => openQuizEditor(Number(b.dataset.edit))));
    root.querySelectorAll('[data-del]').forEach((b) => b.addEventListener('click', async () => {
      if (!confirm('دڵنیایت لە سڕینەوەی ئەم پرسیارە؟')) return;
      db.quizzes[activeQuizScience].splice(Number(b.dataset.del), 1);
      await saveToCloud('پرسیارەکە سڕایەوە ✓');
    }));
  }

  // ===== 8. ORGANIZATION & ACADEMY GOALS =====
  function renderOrganization(root) {
    const org = db.organization || {};
    const goals = Array.isArray(org.academyGoals) ? org.academyGoals : [];

    root.innerHTML = `
      <div class="panel">
        <div class="panel-header">
          <h2>🏛️ زانیارییەکانی ناساندنی ڕێکخراو و فێرگە</h2>
          <button class="btn btn-primary" id="btn-save-org">💾 پاشەکەوتکردن و بڵاوکردنەوە</button>
        </div>
        <div class="form-grid">
          <div class="form-group"><label>ناوی ڕێکخراو (کوردی)</label><input class="input" id="org-ku" value="${esc(org.orgNameKu)}" /></div>
          <div class="form-group"><label>ژێرناوی ڕێکخراو</label><input class="input" id="org-sub" value="${esc(org.orgSubtitleKu)}" /></div>
          <div class="form-group"><label>ناوی ڕێکخراو (عەرەبی)</label><input class="input" id="org-ar" value="${esc(org.orgNameAr)}" /></div>
          <div class="form-group"><label>ناوی ڕێکخراو (ئینگلیزی)</label><input class="input" id="org-en" dir="ltr" value="${esc(org.orgNameEn)}" /></div>
          <div class="form-group full"><label>دروشم (Slogan)</label><input class="input" id="org-slogan" value="${esc(org.slogan)}" /></div>
          <div class="form-group full"><label>پێناسەی ڕێکخراو</label><textarea class="input" id="org-def" rows="4">${esc(org.definition)}</textarea></div>
          <div class="form-group full"><label>بوارەکانی کارکردن (هەر بوارێک لە دێڕێکی نوێدا)</label><textarea class="input" id="org-areas" rows="5">${esc((org.workAreas || []).join('\n'))}</textarea></div>
        </div>
      </div>

      <div class="panel">
        <div class="panel-header">
          <h2>🎯 ئامانجەکانی فێرگەی ڕێبوون (${goals.length})</h2>
          <button class="btn btn-primary btn-sm" id="btn-add-goal">➕ زیادکردنی ئامانج</button>
        </div>
        <div id="org-goals-list">
          ${goals.map((g, i) => `
            <div class="sub-item-row">
              <div class="sub-fields">
                <input class="input" data-g="title" data-i="${i}" placeholder="سەردێڕی ئامانج" value="${esc(g.title)}" />
                <input class="input" data-g="desc" data-i="${i}" placeholder="وردەکاری ئامانج" value="${esc(g.desc)}" />
                <input type="color" data-g="colorHex" data-i="${i}" value="${/^#[0-9A-Fa-f]{6}$/.test(g.colorHex) ? g.colorHex : '#15686C'}" style="width:52px;height:40px;border-radius:10px;border:1px solid var(--border);" />
              </div>
              <button type="button" class="btn btn-danger btn-sm" data-g-del="${i}">✕</button>
            </div>
          `).join('')}
        </div>
      </div>
    `;

    root.querySelectorAll('[data-g]').forEach((inp) => {
      inp.addEventListener('input', () => {
        goals[Number(inp.dataset.i)][inp.dataset.g] = inp.value;
      });
    });

    root.querySelectorAll('[data-g-del]').forEach((b) => {
      b.addEventListener('click', () => {
        goals.splice(Number(b.dataset.gDel), 1);
        db.organization.academyGoals = goals;
        renderOrganization(root);
      });
    });

    $('btn-add-goal').addEventListener('click', () => {
      goals.push({ title: '', desc: '', colorHex: '#15686C' });
      db.organization.academyGoals = goals;
      renderOrganization(root);
    });

    $('btn-save-org').addEventListener('click', async () => {
      db.organization = {
        orgNameKu: $('org-ku').value.trim(),
        orgSubtitleKu: $('org-sub').value.trim(),
        orgNameAr: $('org-ar').value.trim(),
        orgNameEn: $('org-en').value.trim(),
        slogan: $('org-slogan').value.trim(),
        definition: $('org-def').value.trim(),
        workAreas: $('org-areas').value.split('\n').map((s) => s.trim()).filter(Boolean),
        academyGoals: goals.filter((g) => g.title.trim()),
      };
      await saveToCloud('زانیارییەکانی ڕێکخراو و ئامانجەکان پاشەکەوتکران ✓');
    });
  }

  // ===== INIT =====
  if (sessionStorage.getItem(STORAGE_KEY_AUTH) === '1') {
    showDashboard();
  } else {
    showLogin();
  }
})();
