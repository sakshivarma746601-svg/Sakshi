
<!DOCTYPE html>
<html lang="hi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
    <title>MDGS CHAT - Professional Web App</title>
    
    <!-- Firebase SDKs -->
    <script src="https://www.gstatic.com/firebasejs/9.22.0/firebase-app-compat.js"></script>
    <script src="https://www.gstatic.com/firebasejs/9.22.0/firebase-auth-compat.js"></script>
    <script src="https://www.gstatic.com/firebasejs/9.22.0/firebase-database-compat.js"></script>
    
    <style>
        :root {
            --primary: #075e54;
            --primary-dark: #054c44;
            --accent: #25d366;
            --bg-body: #e5ddd5;
            --bg-chat: #efeae2;
            --surface: #ffffff;
            --text-main: #111b21;
            --text-muted: #667781;
        }

        * { box-sizing: border-box; margin: 0; padding: 0; }
        body { 
            font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Helvetica, Arial, sans-serif; 
            background: #d1d7db; 
            display: flex; 
            justify-content: center; 
            align-items: center;
            height: 100vh; 
            overflow: hidden; 
        }

        .app-container { 
            width: 100%; 
            max-width: 440px; 
            height: 100vh; 
            background: var(--surface); 
            display: flex; 
            flex-direction: column; 
            box-shadow: 0 10px 25px rgba(0,0,0,0.15); 
            position: relative; 
            overflow: hidden;
        }

        /* --- AUTH SCREEN --- */
        .auth-screen {
            display: flex;
            flex-direction: column;
            justify-content: center;
            align-items: center;
            height: 100%;
            padding: 30px 20px;
            background: linear-gradient(180deg, var(--primary) 0%, #043933 100%);
            color: white;
            text-align: center;
        }
        .brand-logo {
            width: 70px;
            height: 70px;
            background: white;
            color: var(--primary);
            border-radius: 20px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 32px;
            font-weight: 800;
            box-shadow: 0 8px 16px rgba(0,0,0,0.2);
            margin-bottom: 15px;
        }
        .auth-title { font-size: 24px; font-weight: 700; margin-bottom: 6px; }
        .auth-desc { font-size: 13px; opacity: 0.8; margin-bottom: 35px; max-width: 260px; line-height: 1.4; }
        
        .btn-google {
            background: #ffffff;
            color: #333333;
            width: 100%;
            max-width: 280px;
            padding: 12px 18px;
            border-radius: 25px;
            border: none;
            font-size: 15px;
            font-weight: 600;
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 12px;
            cursor: pointer;
            box-shadow: 0 4px 12px rgba(0,0,0,0.15);
            transition: transform 0.15s, box-shadow 0.15s;
        }
        .btn-google:active { transform: scale(0.97); }
        .btn-google svg { width: 20px; height: 20px; }

        /* --- HEADER --- */
        .header { 
            background: var(--primary); 
            color: white; 
            padding: 12px 16px; 
            display: flex;
            justify-content: space-between;
            align-items: center;
            flex-shrink: 0; 
            box-shadow: 0 2px 5px rgba(0,0,0,0.1);
            z-index: 10;
        }
        .header-title { font-size: 17px; font-weight: 700; letter-spacing: 0.3px; }
        .header-subtitle { font-size: 11px; opacity: 0.85; margin-top: 1px; }
        .header-actions { display: flex; gap: 8px; }
        
        .btn-icon {
            background: rgba(255,255,255,0.15);
            color: white;
            border: none;
            padding: 6px 12px;
            border-radius: 16px;
            font-size: 12px;
            font-weight: 600;
            cursor: pointer;
            transition: background 0.2s;
        }
        .btn-icon:hover { background: rgba(255,255,255,0.25); }

        /* --- UI SCREEN / CHAT LIST --- */
        .ui-body { 
            flex: 1; 
            overflow-y: auto; 
            background: #f0f2f5; 
            display: flex;
            flex-direction: column;
        }
        
        .chat-item {
            background: white;
            padding: 14px 16px;
            display: flex;
            align-items: center;
            gap: 12px;
            border-bottom: 1px solid #f0f0f0;
            cursor: pointer;
            transition: background 0.15s;
        }
        .chat-item:active { background: #f5f5f5; }
        .avatar {
            width: 44px;
            height: 44px;
            border-radius: 50%;
            background: #00a884;
            color: white;
            display: flex;
            align-items: center;
            justify-content: center;
            font-weight: bold;
            font-size: 18px;
            flex-shrink: 0;
        }
        .chat-info { flex: 1; overflow: hidden; }
        .chat-name { font-size: 15px; font-weight: 600; color: var(--text-main); margin-bottom: 2px; }
        .chat-status { font-size: 12px; color: #00a884; font-weight: 500; }

        /* --- CHAT VIEW --- */
        .chat-area { 
            flex: 1; 
            overflow-y: auto; 
            padding: 12px; 
            background: var(--bg-chat); 
            display: flex;
            flex-direction: column;
        }
        .msg { 
            padding: 8px 12px; 
            border-radius: 8px; 
            margin: 4px 0; 
            max-width: 75%; 
            font-size: 14px; 
            line-height: 1.4; 
            word-wrap: break-word; 
            box-shadow: 0 1px 1.5px rgba(0,0,0,0.13);
            position: relative;
        }
        .sent { 
            background: #d9fdd3; 
            align-self: flex-end; 
            border-top-right-radius: 2px;
            color: #111b21;
        }
        .received { 
            background: #ffffff; 
            align-self: flex-start; 
            border-top-left-radius: 2px;
            color: #111b21;
        }

        .input-bar {
            display: flex;
            padding: 10px;
            background: #f0f2f5;
            gap: 8px;
            align-items: center;
            flex-shrink: 0;
        }
        .input-bar input {
            flex: 1;
            padding: 10px 14px;
            border-radius: 20px;
            border: 1px solid #e0e0e0;
            outline: none;
            font-size: 14px;
            background: white;
        }
        .btn-send {
            width: 40px;
            height: 40px;
            border-radius: 50%;
            border: none;
            background: var(--primary);
            color: white;
            font-size: 16px;
            cursor: pointer;
            display: flex;
            align-items: center;
            justify-content: center;
        }

        /* --- CUSTOM MODAL --- */
        .modal-overlay {
            position: absolute;
            top: 0; left: 0; right: 0; bottom: 0;
            background: rgba(0,0,0,0.5);
            display: none;
            align-items: center;
            justify-content: center;
            z-index: 1000;
            padding: 20px;
        }
        .modal-card {
            background: white;
            width: 100%;
            max-width: 320px;
            border-radius: 12px;
            padding: 20px;
            box-shadow: 0 10px 25px rgba(0,0,0,0.2);
            text-align: center;
        }
        .modal-title { font-size: 16px; font-weight: 700; margin-bottom: 12px; color: var(--text-main); }
        .modal-input {
            width: 100%;
            padding: 10px;
            border: 1px solid #ccc;
            border-radius: 6px;
            margin-bottom: 15px;
            font-size: 14px;
            outline: none;
        }
        .modal-btn {
            width: 100%;
            padding: 10px;
            background: var(--primary);
            color: white;
            border: none;
            border-radius: 6px;
            font-weight: 600;
            cursor: pointer;
        }

        /* TOP PROGRESS BAR LOADER */
        #top-loader {
            position: absolute;
            top: 0; left: 0;
            width: 100%;
            height: 3px;
            background: #25d366;
            display: none;
            z-index: 9999;
            animation: loadingBar 1.2s infinite ease-in-out;
        }
        @keyframes loadingBar {
            0% { transform: translateX(-100%); }
            100% { transform: translateX(100%); }
        }
    </style>
</head>
<body>

<div class="app-container">
    <div id="top-loader"></div>

    <!-- MAIN APP STRUCTURE -->
    <div id="app-view" style="display:none; height:100%; flex-direction:column;">
        <div class="header">
            <div>
                <div class="header-title">MDGS CHAT</div>
                <div id="user-info" class="header-subtitle"></div>
            </div>
            <div class="header-actions">
                <button class="btn-icon" onclick="openAddFriendModal()">➕ दोस्त</button>
                <button class="btn-icon" style="background:#d9534f;" onclick="logout()">🚪</button>
            </div>
        </div>

        <div id="ui" class="ui-body"></div>
    </div>

    <!-- AUTH / LOGIN SCREEN -->
    <div id="auth-view" class="auth-screen">
        <div class="brand-logo">M</div>
        <div class="auth-title">MDGS.CHAT</div>
        <div class="auth-desc">सुरक्षित और सुपर-फास्ट चैटिंग अनुभव के लिए लॉगिन करें।</div>
        
        <button class="btn-google" onclick="signInWithGoogle()">
            <svg viewBox="0 0 48 48">
                <path fill="#EA4335" d="M24 9.5c3.54 0 6.71 1.22 9.21 3.6l6.85-6.85C35.9 2.38 30.47 0 24 0 14.62 0 6.51 5.38 2.56 13.22l7.98 6.19C12.43 13.72 17.74 9.5 24 9.5z"/>
                <path fill="#4285F4" d="M46.98 24.55c0-1.57-.15-3.09-.38-4.55H24v9.02h12.94c-.58 2.96-2.26 5.48-4.78 7.18l7.73 6c4.51-4.18 7.09-10.36 7.09-17.65z"/>
                <path fill="#FBBC05" d="M10.53 28.59c-.48-1.45-.76-2.99-.76-4.59s.27-3.14.76-4.59l-7.98-6.19C.92 16.46 0 20.12 0 24c0 3.88.92 7.54 2.56 10.78l7.97-6.19z"/>
                <path fill="#34A853" d="M24 48c6.48 0 11.93-2.13 15.89-5.81l-7.73-6c-2.15 1.45-4.92 2.3-8.16 2.3-6.26 0-11.57-4.22-13.47-9.91l-7.98 6.19C6.51 42.62 14.62 48 24 48z"/>
            </svg>
            Google से लॉगिन करें
        </button>
    </div>

    <!-- CUSTOM INPUT MODAL -->
    <div id="modal" class="modal-overlay">
        <div class="modal-card">
            <div id="modal-title" class="modal-title">इनपुट दर्ज करें</div>
            <input id="modal-input" class="modal-input" placeholder="...">
            <button id="modal-submit" class="modal-btn">सबमिट करें</button>
        </div>
    </div>
</div>

<script>
    // Firebase Config
    const firebaseConfig = {
        apiKey: "AIzaSyDmNjjJRXT94RvhvLAmiPPpuo-Su3pd9Tc",
        authDomain: "mdgs-chat-com.firebaseapp.com",
        databaseURL: "https://mdgs-chat-com-default-rtdb.firebaseio.com",
        projectId: "mdgs-chat-com"
    };
    
    if (!firebase.apps.length) firebase.initializeApp(firebaseConfig);

    let activeChatRef = null;

    function showLoader() { document.getElementById('top-loader').style.display = 'block'; }
    function hideLoader() { document.getElementById('top-loader').style.display = 'none'; }

    function getRoomId(uid1, uid2) {
        return uid1 < uid2 ? `${uid1}_${uid2}` : `${uid2}_${uid1}`;
    }

    // Modern Modal Input Helper
    function customPrompt(title, placeholder, callback) {
        const modal = document.getElementById('modal');
        const titleEl = document.getElementById('modal-title');
        const inputEl = document.getElementById('modal-input');
        const btn = document.getElementById('modal-submit');

        titleEl.innerText = title;
        inputEl.placeholder = placeholder;
        inputEl.value = '';
        modal.style.display = 'flex';
        inputEl.focus();

        btn.onclick = () => {
            const val = inputEl.value.trim();
            if (val) {
                modal.style.display = 'none';
                callback(val);
            }
        };
    }

    // Process Redirect Result (Mobile Browser Support)
    showLoader();
    firebase.auth().getRedirectResult()
        .then(() => hideLoader())
        .catch((error) => {
            hideLoader();
            if (error.code) alert("लॉगिन त्रुटि: " + error.message);
        });

    // FIXED Google Sign-In with Automatic Fallback
    window.signInWithGoogle = function() {
        showLoader();
        const provider = new firebase.auth.GoogleAuthProvider();
        
        firebase.auth().signInWithPopup(provider)
            .then(() => hideLoader())
            .catch((error) => {
                // If popup is blocked or unsupported, fallback to Redirect
                if (error.code === 'auth/popup-blocked' || error.code === 'auth/operation-not-supported-in-this-environment' || error.code === 'auth/popup-closed-by-user') {
                    firebase.auth().signInWithRedirect(provider);
                } else {
                    hideLoader();
                    alert("लॉगिन एरर: " + error.message);
                }
            });
    };

    window.logout = function() {
        if (confirm("लॉगआउट करना चाहते हैं?")) {
            if (activeChatRef) activeChatRef.off();
            localStorage.clear();
            firebase.auth().signOut().then(() => window.location.reload());
        }
    };

    // Auth Change Listener
    firebase.auth().onAuthStateChanged(user => {
        hideLoader();
        if (user) {
            document.getElementById('auth-view').style.display = 'none';
            document.getElementById('app-view').style.display = 'flex';
            checkUsername(user);
        } else {
            document.getElementById('auth-view').style.display = 'flex';
            document.getElementById('app-view').style.display = 'none';
        }
    });

    function checkUsername(user) {
        const cachedUser = localStorage.getItem('uname_' + user.uid);
        if (cachedUser) {
            document.getElementById('user-info').innerText = "स्वागत: " + cachedUser;
            loadList();
            return;
        }

        showLoader();
        firebase.database().ref('users/' + user.uid).once('value')
            .then(snap => {
                hideLoader();
                if (snap.exists() && snap.val().username) {
                    const uname = snap.val().username;
                    localStorage.setItem('uname_' + user.uid, uname);
                    document.getElementById('user-info').innerText = "स्वागत: " + uname;
                    loadList();
                } else {
                    customPrompt("अपना यूजरनेम बनाएं", "जैसे: rahul_01", (u) => {
                        showLoader();
                        firebase.database().ref('users/' + user.uid).set({ 
                            username: u, 
                            email: user.email 
                        }).then(() => {
                            localStorage.setItem('uname_' + user.uid, u);
                            checkUsername(user);
                        });
                    });
                }
            });
    }

    // Load Chat List
    window.loadList = function() {
        if (activeChatRef) { activeChatRef.off(); activeChatRef = null; }

        const ui = document.getElementById('ui');
        ui.innerHTML = '<div id="list" style="padding:4px 0;"></div>';
        
        const myUid = firebase.auth().currentUser.uid;
        
        const cachedFriends = localStorage.getItem('friends_' + myUid);
        if (cachedFriends) renderFriendList(JSON.parse(cachedFriends));

        firebase.database().ref('friends/' + myUid).once('value').then(snap => {
            if (snap.exists()) {
                const data = snap.val();
                localStorage.setItem('friends_' + myUid, JSON.stringify(data));
                renderFriendList(data);
            } else if (!cachedFriends) {
                document.getElementById('list').innerHTML = `
                    <div style="text-align:center; color:#777; margin-top:50px; padding:20px;">
                        <p style="font-size:14px; margin-bottom:10px;">कोई चैट उपलब्ध नहीं है</p>
                        <small>"➕ दोस्त" बटन दबाकर नए दोस्तों को जोड़ें</small>
                    </div>`;
            }
        });
    };

    function renderFriendList(data) {
        const listDiv = document.getElementById('list');
        if (!listDiv) return;
        listDiv.innerHTML = '';
        const fragment = document.createDocumentFragment();
        
        Object.keys(data).forEach(friendUid => {
            const name = data[friendUid].username || "यूजर";
            const firstLetter = name.charAt(0).toUpperCase();

            const item = document.createElement('div');
            item.className = 'chat-item';
            item.onclick = () => openChat(friendUid, name);
            item.innerHTML = `
                <div class="avatar">${firstLetter}</div>
                <div class="chat-info">
                    <div class="chat-name">${name}</div>
                    <div class="chat-status">ऑनलाइन 🟢</div>
                </div>`;
            fragment.appendChild(item);
        });
        listDiv.appendChild(fragment);
    }

    // Open Chat Screen
    window.openChat = function(friendUid, username) {
        const myUid = firebase.auth().currentUser.uid;
        const roomId = getRoomId(myUid, friendUid);

        const ui = document.getElementById('ui');
        ui.innerHTML = `
            <div style="background:#075e54; color:white; padding:10px 14px; display:flex; align-items:center; gap:10px; flex-shrink:0;">
                <button onclick="loadList()" style="background:none; border:none; color:white; font-size:18px; cursor:pointer;">←</button>
                <div style="font-weight:600; font-size:15px;">${username}</div>
            </div>
            <div id="msg-area" class="chat-area"></div>
            <div class="input-bar">
                <input id="in" placeholder="मैसेज लिखें..." autocomplete="off">
                <button class="btn-send" onclick="sendMsg('${friendUid}')">➤</button>
            </div>`;
        
        const area = document.getElementById('msg-area');
        const inputField = document.getElementById('in');
        inputField.addEventListener("keyup", (e) => { if (e.key === "Enter") sendMsg(friendUid); });

        if (activeChatRef) activeChatRef.off();

        const loadedKeys = new Set();
        let cachedMsgs = JSON.parse(localStorage.getItem('chat_' + roomId) || '[]');

        if (cachedMsgs.length > 0) {
            const fragment = document.createDocumentFragment();
            cachedMsgs.forEach(m => {
                loadedKeys.add(m.key);
                const msgEl = document.createElement('div');
                msgEl.className = `msg ${m.from === myUid ? 'sent' : 'received'}`;
                msgEl.textContent = m.text;
                fragment.appendChild(msgEl);
            });
            area.appendChild(fragment);
            area.scrollTop = area.scrollHeight;
        }

        activeChatRef = firebase.database().ref('chats/' + roomId).limitToLast(30);
        activeChatRef.on('child_added', snap => {
            const key = snap.key;
            if (!loadedKeys.has(key)) {
                loadedKeys.add(key);
                const m = snap.val();
                
                cachedMsgs.push({ key: key, from: m.from, text: m.text });
                if (cachedMsgs.length > 50) cachedMsgs.shift();
                localStorage.setItem('chat_' + roomId, JSON.stringify(cachedMsgs));

                const msgEl = document.createElement('div');
                msgEl.className = `msg ${m.from === myUid ? 'sent' : 'received'}`;
                msgEl.textContent = m.text;
                area.appendChild(msgEl);
                area.scrollTop = area.scrollHeight;
            }
        });
    };

    window.sendMsg = function(friendUid) {
        const inputField = document.getElementById('in');
        const text = inputField.value.trim();
        if (text) {
            const myUid = firebase.auth().currentUser.uid;
            const roomId = getRoomId(myUid, friendUid);
            
            firebase.database().ref('chats/' + roomId).push({ 
                from: myUid, 
                to: friendUid, 
                text: text, 
                timestamp: Date.now() 
            });
            inputField.value = '';
            inputField.focus();
        }
    };

    window.openAddFriendModal = function() {
        customPrompt("नए दोस्त का यूजरनेम लिखें", "यूजरनेम दर्ज करें...", (username) => {
            showLoader();
            const cleanName = username.trim();
            firebase.database().ref('users/').orderByChild('username').equalTo(cleanName).once('value')
                .then(snap => {
                    hideLoader();
                    if (snap.exists()) {
                        const fUid = Object.keys(snap.val())[0];
                        const myUid = firebase.auth().currentUser.uid;
                        if (fUid === myUid) return alert("आप स्वयं को दोस्त नहीं बना सकते!");
                        
                        firebase.database().ref('users/' + myUid).once('value').then(mySnap => {
                            const myName = mySnap.val() ? mySnap.val().username : "यूजर";
                            firebase.database().ref('friends/' + myUid + '/' + fUid).set({ username: cleanName });
                            firebase.database().ref('friends/' + fUid + '/' + myUid).set({ username: myName });
                            loadList();
                        });
                    } else {
                        alert("यूजर नहीं मिला!");
                    }
                });
        });
    };
</script>
</body>
</html>
