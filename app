<!DOCTYPE html>
<html>
<head>
    <title>Aim Trainer</title>
    <style>
        body {
            margin: 0;
            display: flex;
            flex-direction: column;
            align-items: center;
            background-color: #1a1a1a;
            color: white;
            font-family: Arial, sans-serif;
        }

        #gameArea {
            width: 800px;
            height: 600px;
            background-color: #2d2d2d;
            position: relative;
            cursor: crosshair;
            margin: 20px;
            overflow: hidden;
            border-radius: 10px;
            box-shadow: 0 0 20px rgba(0,0,0,0.5);
        }

        .target {
            position: absolute;
            border-radius: 50%;
            cursor: pointer;
            background: conic-gradient(
                from 0deg,
                #ff4444,
                #ff8f1c,
                #fff01f,
                #48ff3c,
                #2cffea,
                #4d6bff,
                #ff4444
            );
        }

        .target::before {
            content: '';
            position: absolute;
            top: 50%;
            left: 50%;
            width: 85%;
            height: 85%;
            transform: translate(-50%, -50%);
            background: radial-gradient(circle at center,
                rgba(255, 255, 255, 0.9) 0%,
                rgba(255, 255, 255, 0.8) 20%,
                rgba(255, 255, 255, 0) 70%
            );
            border-radius: 50%;
            animation: pulse 2s infinite;
        }

        .target::after {
            content: '';
            position: absolute;
            top: 50%;
            left: 50%;
            width: 50%;
            height: 50%;
            transform: translate(-50%, -50%);
            background: radial-gradient(circle at center,
                #ff4444 0%,
                rgba(255, 68, 68, 0.8) 50%,
                rgba(255, 68, 68, 0) 100%
            );
            border-radius: 50%;
        }

        @keyframes spawn {
            from {
                transform: scale(0) rotate(180deg);
            }
            to {
                transform: scale(1) rotate(0deg);
            }
        }

        @keyframes pulse {
            0% { opacity: 0.5; }
            50% { opacity: 1; }
            100% { opacity: 0.5; }
        }

        #controls {
            margin: 20px;
            padding: 20px;
            background-color: #333;
            border-radius: 10px;
            box-shadow: 0 0 10px rgba(0,0,0,0.3);
        }

        .control-group {
            margin: 10px 0;
            display: flex;
            align-items: center;
            gap: 10px;
        }

        label {
            min-width: 140px;
        }

        input[type="range"] {
            width: 200px;
            height: 8px;
            background: #4CAF50;
            border-radius: 4px;
            -webkit-appearance: none;
        }

        input[type="range"]::-webkit-slider-thumb {
            -webkit-appearance: none;
            width: 20px;
            height: 20px;
            background: #fff;
            border-radius: 50%;
            cursor: pointer;
            box-shadow: 0 0 5px rgba(0,0,0,0.3);
        }

        #stats {
            font-size: 18px;
            margin: 10px;
            display: grid;
            grid-template-columns: auto auto;
            gap: 20px;
            background-color: #333;
            padding: 15px;
            border-radius: 10px;
            box-shadow: 0 0 10px rgba(0,0,0,0.3);
        }

        .stat-group {
            display: flex;
            gap: 20px;
            align-items: center;
        }

        button {
            background-color: #4CAF50;
            color: white;
            padding: 12px 24px;
            border: none;
            border-radius: 5px;
            cursor: pointer;
            margin: 5px;
            font-size: 16px;
            transition: all 0.2s ease;
            box-shadow: 0 2px 5px rgba(0,0,0,0.2);
        }

        button:hover {
            background-color: #45a049;
            transform: translateY(-1px);
            box-shadow: 0 3px 7px rgba(0,0,0,0.3);
        }

        button:active {
            transform: translateY(1px);
            box-shadow: 0 1px 3px rgba(0,0,0,0.2);
        }

        .hit-effect {
            position: absolute;
            pointer-events: none;
            animation: hitEffect 0.3s ease-out forwards;
        }

        @keyframes hitEffect {
            0% {
                transform: scale(0);
                opacity: 1;
            }
            100% {
                transform: scale(2);
                opacity: 0;
            }
        }

        #timer {
            font-family: monospace;
            font-size: 24px;
            color: #4CAF50;
            text-shadow: 0 0 10px rgba(76, 175, 80, 0.3);
        }

        .stat-value {
            font-weight: bold;
            color: #4CAF50;
        }
    </style>
</head>
<body>
    <div id="controls">
        <div class="control-group">
            <label for="targetsPerSec">Targets per second:</label>
            <input type="range" id="targetsPerSec" min="0.2" max="5" step="0.1" value="4">
            <span id="targetsPerSecValue">4.0</span>
        </div>
        <div class="control-group">
            <label for="targetSize">Target Size (px):</label>
            <input type="range" id="targetSize" min="20" max="100" value="100">
            <span id="targetSizeValue">100</span>
        </div>
        <div class="control-group">
            <label for="animationSpeed">Animation Speed (sec):</label>
            <input type="range" id="animationSpeed" min="0.1" max="2.0" value="1.5" step="0.1">
            <span id="animationSpeedValue">0.3</span>
        </div>
        <button id="startGame">Start Game</button>
        <button id="resetGame">Reset Game</button>
    </div>
    <div id="stats">
        <div class="stat-group">
            <span>Hits: <span id="hits" class="stat-value">0</span></span>
            <span>Misses: <span id="misses" class="stat-value">0</span></span>
            <span>Accuracy: <span id="accuracy" class="stat-value">0</span>%</span>
        </div>
        <div class="stat-group">
            <span>Time: <span id="timer">00:00:00</span></span>
        </div>
    </div>
    <div id="gameArea"></div>

    <script>
        const gameArea = document.getElementById('gameArea');
        const targetsPerSecInput = document.getElementById('targetsPerSec');
        const targetSizeInput = document.getElementById('targetSize');
        const animationSpeedInput = document.getElementById('animationSpeed');
        const targetsPerSecValue = document.getElementById('targetsPerSecValue');
        const targetSizeValue = document.getElementById('targetSizeValue');
        const animationSpeedValue = document.getElementById('animationSpeedValue');
        const startButton = document.getElementById('startGame');
        const resetButton = document.getElementById('resetGame');
        const hitsElement = document.getElementById('hits');
        const missesElement = document.getElementById('misses');
        const accuracyElement = document.getElementById('accuracy');
        const timerElement = document.getElementById('timer');

        let gameRunning = false;
        let spawnInterval;
        let hits = 0;
        let misses = 0;
        let audioContext;
        let startTime;
        let timerInterval;

        document.addEventListener('click', function initAudio() {
            if (!audioContext) {
                audioContext = new (window.AudioContext || window.webkitAudioContext)();
            }
            document.removeEventListener('click', initAudio);
        });

        function playSound(frequency, duration, type = 'sine') {
            if (!audioContext) return;
            
            const oscillator = audioContext.createOscillator();
            const gainNode = audioContext.createGain();
            
            oscillator.type = type;
            oscillator.frequency.setValueAtTime(frequency, audioContext.currentTime);
            
            gainNode.gain.setValueAtTime(0.3, audioContext.currentTime);
            gainNode.gain.exponentialRampToValueAtTime(0.01, audioContext.currentTime + duration);
            
            oscillator.connect(gainNode);
            gainNode.connect(audioContext.destination);
            
            oscillator.start();
            oscillator.stop(audioContext.currentTime + duration);
        }

        function updateAnimationSpeed() {
            const speed = parseFloat(animationSpeedInput.value).toFixed(1);
            animationSpeedValue.textContent = speed;
        }

        function updateTargetsPerSecDisplay() {
            targetsPerSecValue.textContent = parseFloat(targetsPerSecInput.value).toFixed(1);
            if (gameRunning) {
                clearInterval(spawnInterval);
                const spawnRate = Math.round(1000 / parseFloat(targetsPerSecInput.value));
                spawnInterval = setInterval(createTarget, spawnRate);
            }
        }

        function updateTargetSizeDisplay() {
            targetSizeValue.textContent = targetSizeInput.value;
        }

        function formatTime(ms) {
            const hours = String(Math.floor(ms / 3600000)).padStart(2, '0');
            const minutes = String(Math.floor((ms % 3600000) / 60000)).padStart(2, '0');
            const seconds = String(Math.floor((ms % 60000) / 1000)).padStart(2, '0');
            return `${hours}:${minutes}:${seconds}`;
        }

        function updateTimer() {
            if (gameRunning && startTime) {
                const elapsed = Date.now() - startTime;
                timerElement.textContent = formatTime(elapsed);
            }
        }

        function createTarget() {
            const size = parseInt(targetSizeInput.value);
            const target = document.createElement('div');
            target.className = 'target';
            target.style.width = size + 'px';
            target.style.height = size + 'px';
            target.style.animation = `spawn ${animationSpeedInput.value * 1000}ms ease-out`;
            
            const maxX = gameArea.clientWidth - size;
            const maxY = gameArea.clientHeight - size;
            target.style.left = Math.random() * maxX + 'px';
            target.style.top = Math.random() * maxY + 'px';
            
            target.addEventListener('mousedown', hitTarget);
            target.addEventListener('contextmenu', (e) => e.preventDefault());
            gameArea.appendChild(target);

            setTimeout(() => {
                if (target.parentNode === gameArea) {
                    target.remove();
                    misses++;
                    updateStats();
                }
            }, 2000);
        }

        function createHitEffect(x, y) {
            const effect = document.createElement('div');
            effect.className = 'hit-effect';
            effect.style.left = x + 'px';
            effect.style.top = y + 'px';
            effect.style.width = '20px';
            effect.style.height = '20px';
            effect.style.backgroundColor = '#fff';
            effect.style.borderRadius = '50%';
            gameArea.appendChild(effect);
            
            setTimeout(() => effect.remove(), 300);
        }

        function hitTarget(e) {
            e.preventDefault();
            e.target.remove();
            hits++;
            updateStats();
            playSound(880, 0.1, 'sine');
            createHitEffect(e.pageX - gameArea.offsetLeft, e.pageY - gameArea.offsetTop);
        }

        function updateStats() {
            hitsElement.textContent = hits;
            missesElement.textContent = misses;
            const total = hits + misses;
            const accuracy = total > 0 ? Math.round((hits / total) * 100) : 0;
            accuracyElement.textContent = accuracy;
        }

        function startGame() {
            if (!gameRunning) {
                gameRunning = true;
                startTime = startTime || Date.now();
                const spawnRate = Math.round(1000 / parseFloat(targetsPerSecInput.value));
                spawnInterval = setInterval(createTarget, spawnRate);
                timerInterval = setInterval(updateTimer, 1000);
                startButton.textContent = 'Pause Game';
            } else {
                gameRunning = false;
                clearInterval(spawnInterval);
                clearInterval(timerInterval);
                startButton.textContent = 'Resume Game';
            }
        }

        function resetGame() {
            gameRunning = false;
            clearInterval(spawnInterval);
            clearInterval(timerInterval);
            gameArea.innerHTML = '';
            hits = 0;
            misses = 0;
            startTime = null;
            timerElement.textContent = '00:00:00';
            updateStats();
            startButton.textContent = 'Start Game';
        }

        gameArea.addEventListener('mousedown', (e) => {
            if (e.target === gameArea) {
                e.preventDefault();
                misses++;
                updateStats();
            }
        });

        gameArea.addEventListener('contextmenu', (e) => {
            e.preventDefault();
        });

        targetsPerSecInput.addEventListener('input', updateTargetsPerSecDisplay);
        targetSizeInput.addEventListener('input', updateTargetSizeDisplay);
        animationSpeedInput.addEventListener('input', updateAnimationSpeed);
        startButton.addEventListener('click', startGame);
        resetButton.addEventListener('click', resetGame);

        updateTargetsPerSecDisplay();
        updateTargetSizeDisplay();
        updateAnimationSpeed();
    </script>
</body>
</html>