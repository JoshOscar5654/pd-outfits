let currentLanguage = 'en'; // Change as needed for your default language, or add in locales/ect.
let currentOutfits = [];
let selectedOutfitId = null;

window.addEventListener('message', function(event) {
    const data = event.data;
    if (data.action === 'open') {
        currentLanguage = data.language || 'en';
        applyLocales();
        
        document.body.classList.remove('closing');
        document.body.style.display = 'block';
    } else if (data.action === 'updateList') {
        currentOutfits = data.outfits;
        renderOutfits(currentOutfits);
    }
});

function applyLocales() {
    const lang = Locales[currentLanguage] || Locales['en'];
    document.getElementById('ui-title').textContent = lang.title;
    document.getElementById('ui-subtitle').textContent = lang.sub_title;
    document.getElementById('search').placeholder = lang.search_placeholder;
    document.getElementById('create-btn').textContent = lang.create_btn;
    document.getElementById('ui-footer').textContent = lang.footer_credit;
    document.getElementById('modal-cancel').textContent = lang.btn_cancel;
}

// Close on Escape Key
document.onkeyup = function(data) {
    if (data.key === 'Escape') closeUI();
};

function closeUI() {
    document.body.classList.add('closing');

    setTimeout(() => {
        document.body.style.display = 'none';
        
        fetch(`https://${GetParentResourceName()}/close`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json; charset=UTF-8' },
            body: JSON.stringify({})
        });
    }, 400);
}

function renderOutfits(outfits) {
    const list = document.getElementById('outfit-list');
    list.innerHTML = '';
    const lang = Locales[currentLanguage];

    if (!outfits || outfits.length === 0) {
        list.innerHTML = `<div style="text-align:center; color: #666; padding: 20px; font-size: 13px;">${lang.empty_list}</div>`;
        return;
    }

    outfits.forEach((outfit, index) => {
        const item = document.createElement('div');
        item.classList.add('outfit-item');
        item.style.animationDelay = `${index * 0.05}s`; 
        
        item.innerHTML = `
            <span class="outfit-name">${outfit.name}</span>
            <div class="outfit-actions">
                <button class="icon-btn" onclick="useOutfit(${outfit.id})"><i class="fa-solid fa-shirt"></i></button>
                <button class="icon-btn" onclick="openEditModal(${outfit.id}, '${outfit.name}')"><i class="fa-solid fa-pen"></i></button>
                <button class="icon-btn delete" onclick="openDeleteModal(${outfit.id})"><i class="fa-solid fa-trash"></i></button>
            </div>
        `;
        item.querySelector('.outfit-name').onclick = () => useOutfit(outfit.id);
        list.appendChild(item);
    });
}

document.getElementById('search').addEventListener('input', function(e) {
    const term = e.target.value.toLowerCase();
    const filtered = currentOutfits.filter(o => o.name.toLowerCase().includes(term));
    renderOutfits(filtered);
});

function useOutfit(id) {
    const outfit = currentOutfits.find(o => o.id === id);
    if (!outfit) return;
    fetch(`https://${GetParentResourceName()}/useOutfit`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json; charset=UTF-8' },
        body: JSON.stringify({ outfit: outfit })
    });
}

document.getElementById('create-btn').addEventListener('click', () => {
    openInputModal('save');
});

const modal = document.getElementById('modal');
const modalTitle = document.getElementById('modal-title');
const modalDesc = document.getElementById('modal-desc');
const modalInput = document.getElementById('modal-input');
const confirmBtn = document.getElementById('modal-confirm');
let currentAction = null;
let targetId = null;

function openDeleteModal(id) {
    const lang = Locales[currentLanguage];
    targetId = id;
    currentAction = 'delete';
    modalTitle.textContent = lang.delete_confirm_title;
    modalDesc.textContent = lang.delete_confirm_desc;
    modalDesc.style.display = 'block';
    modalInput.style.display = 'none';
    confirmBtn.textContent = lang.btn_confirm;
    confirmBtn.className = 'btn-danger'; 
    modal.classList.add('active');
}

function openEditModal(id, oldName) {
    const lang = Locales[currentLanguage];
    targetId = id;
    currentAction = 'edit';
    modalTitle.textContent = lang.edit_placeholder;
    modalDesc.style.display = 'none';
    modalInput.style.display = 'block';
    modalInput.value = oldName;
    confirmBtn.textContent = lang.btn_save;
    confirmBtn.className = 'btn-primary';
    modal.classList.add('active');
    modalInput.focus();
}

function openInputModal(type) {
    const lang = Locales[currentLanguage];
    currentAction = type;
    modalTitle.textContent = lang.edit_placeholder;
    modalDesc.style.display = 'none';
    modalInput.style.display = 'block';
    modalInput.value = '';
    confirmBtn.textContent = lang.btn_save;
    confirmBtn.className = 'btn-primary';
    modal.classList.add('active');
    modalInput.focus();
}

document.getElementById('modal-cancel').addEventListener('click', () => {
    modal.classList.remove('active');
});

confirmBtn.addEventListener('click', () => {
    if (currentAction === 'delete') {
        fetch(`https://${GetParentResourceName()}/deleteOutfit`, {
            method: 'POST',
            body: JSON.stringify({ id: targetId })
        });
    } else if (currentAction === 'edit') {
        const newName = modalInput.value;
        if (newName) {
            fetch(`https://${GetParentResourceName()}/editOutfit`, {
                method: 'POST',
                body: JSON.stringify({ id: targetId, newName: newName })
            });
        }
    } else if (currentAction === 'save') {
        const name = modalInput.value;
        if (name) {
            fetch(`https://${GetParentResourceName()}/saveOutfit`, {
                method: 'POST',
                body: JSON.stringify({ name: name })
            });
        }
    }
    modal.classList.remove('active');
});