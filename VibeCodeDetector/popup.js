document.addEventListener('DOMContentLoaded', () => {
  const scanBtn = document.getElementById('scan-btn');
  const loadingDiv = document.getElementById('loading');
  const resultsContainer = document.getElementById('results-container');
  const copyPromptBtn = document.getElementById('copy-prompt-btn');
  
  scanBtn.addEventListener('click', async () => {
    // Show loading state
    scanBtn.disabled = true;
    scanBtn.textContent = 'Scanning...';
    loadingDiv.style.display = 'block';
    resultsContainer.style.display = 'none';
    
    try {
      // Get active tab
      const [tab] = await chrome.tabs.query({ active: true, currentWindow: true });
      
      // Send message to content script
      chrome.tabs.sendMessage(tab.id, { action: "scan" }, (response) => {
        loadingDiv.style.display = 'none';
        scanBtn.disabled = false;
        scanBtn.textContent = 'Scan Again';
        
        if (chrome.runtime.lastError) {
          document.getElementById('verdict').textContent = "Connection Error"; 
          document.getElementById('verdict').style.color = "red"; 
          document.getElementById('loading').innerHTML = "<p style='color:red; font-size:12px; margin-top:10px;'>Please REFRESH the webpage you are trying to scan, then click scan again.</p>"; 
          loadingDiv.style.display = "block";
          return;
        }
        
        if (response && response.error) {
          document.getElementById('verdict').textContent = "Scan Failed"; 
          loadingDiv.innerHTML = "<p style='color:red; font-size:12px; margin-top:10px;'>" + response.error + "</p>"; 
          loadingDiv.style.display = "block";
          return;
        }
        
        if (response) {
          displayResults(response);
        }
      });
    } catch (error) {
      loadingDiv.style.display = 'none';
      scanBtn.disabled = false;
      scanBtn.textContent = 'Scan This Website';
      alert("Unexpected error: " + error.message);
    }
  });
  
  copyPromptBtn.addEventListener('click', () => {
    const promptText = document.getElementById('prompt-text');
    promptText.select();
    document.execCommand('copy');
    
    const originalText = copyPromptBtn.textContent;
    copyPromptBtn.textContent = 'Copied!';
    setTimeout(() => {
      copyPromptBtn.textContent = originalText;
    }, 2000);
  });

  const downloadReportBtn = document.getElementById('download-report-btn');
  downloadReportBtn.addEventListener('click', () => {
    if(!window.lastScanData) return;
    const d = window.lastScanData;
    
    let reportHTML = `
      <html>
      <head>
        <title>Vibe Code Audit Report</title>
        <style>
          body { font-family: Arial, sans-serif; line-height: 1.6; color: #333; max-width: 800px; margin: 40px auto; padding: 20px; }
          h1 { color: #2563eb; border-bottom: 2px solid #e5e7eb; padding-bottom: 10px; }
          .score-card { background: #f3f4f6; padding: 20px; border-radius: 8px; margin-bottom: 20px; text-align: center; }
          .score { font-size: 48px; font-weight: bold; color: ${d.verdictColor}; }
          .verdict { font-size: 24px; font-weight: bold; margin-bottom: 10px; }
          .category { margin-bottom: 20px; border: 1px solid #e5e7eb; padding: 15px; border-radius: 8px; }
          .cat-title { font-weight: bold; font-size: 18px; margin-bottom: 10px; display: flex; justify-content: space-between; }
          .critical { color: #dc2626; font-weight: bold; }
          .high { color: #ea580c; }
          .medium { color: #d97706; }
          .low { color: #ca8a04; }
          .clean { color: #16a34a; }
          .prompt { background: #1e293b; color: #38bdf8; padding: 15px; border-radius: 8px; font-family: monospace; white-space: pre-wrap; }
        </style>
      </head>
      <body>
        <h1>🔍 Vibe Code Detector - Audit Report</h1>
        <p><strong>Target URL:</strong> ${d.url}</p>
        <p><strong>Scan Date:</strong> ${new Date(d.timestamp).toLocaleString()}</p>
        
        <div class="score-card">
          <div class="score">${d.totalScore}/100</div>
          <div class="verdict">${d.verdict}</div>
          <p><em>Note: A higher score indicates a higher probability of AI-generated code and potential security shortcuts.</em></p>
        </div>
        
        <h2>Detailed Findings</h2>
    `;
    
    const cats = [
      { key: 'meta', label: 'Meta Fingerprints' },
      { key: 'framework', label: 'Framework & CSS' },
      { key: 'cdn', label: 'CDN & Pipeline' },
      { key: 'quality', label: 'Code Quality' },
      { key: 'security', label: 'Security Flags' }
    ];
    
    cats.forEach(c => {
      const catData = d.categories[c.key];
      reportHTML += `<div class="category">
        <div class="cat-title"><span>${c.label}</span> <span>Score: ${catData.score}/20</span></div>
        <ul>`;
      catData.findings.forEach(f => {
        reportHTML += `<li class="${f.severity}">${f.text}</li>`;
      });
      reportHTML += `</ul></div>`;
    });
    
    reportHTML += `
      <h2>🤖 AI Improvement Prompt</h2>
      <p>Use this prompt in ChatGPT, Cursor, or v0 to fix the detected issues:</p>
      <div class="prompt">${document.getElementById('prompt-text').value}</div>
      
      <p style="text-align: center; margin-top: 40px; color: #6b7280; font-size: 12px;">Generated by Vibe Code Detector Chrome Extension</p>
      
      <script>
        // Auto-trigger print dialog for PDF saving
        window.onload = () => { window.print(); };
      </script>
      </body>
      </html>
    `;
    
    const blob = new Blob([reportHTML], { type: 'text/html' });
    const url = URL.createObjectURL(blob);
    const a = document.createElement('a');
    a.href = url;
    a.download = 'VibeCode_Audit_Report.html';
    a.click();
    URL.revokeObjectURL(url);
  });

});


function displayResults(data) {
  const resultsContainer = document.getElementById('results-container');
  resultsContainer.style.display = 'block';
  
  // Update Score Card
  const scoreValue = document.getElementById('score-value');
  const verdictEl = document.getElementById('verdict');
  const circleProgress = document.getElementById('circle-progress');
  const scoreGlow = document.getElementById('score-glow');
  
  // Animate numbers
  window.lastScanData = data;
  let currentScore = 0;
  const targetScore = data.totalScore;
  const duration = 1000;
  const steps = 30;
  const stepTime = Math.abs(Math.floor(duration / steps));
  
  const timer = setInterval(() => {
    currentScore += Math.ceil(targetScore / steps);
    if (currentScore >= targetScore) {
      currentScore = targetScore;
      clearInterval(timer);
    }
    scoreValue.textContent = currentScore;
  }, stepTime);
  
  // Animate SVG Ring
  setTimeout(() => {
    circleProgress.style.strokeDasharray = `${data.totalScore}, 100`;
    circleProgress.style.stroke = data.verdictColor;
  }, 100);
  
  
  // Generate Roast
  const roastBox = document.getElementById('roast-box');
  let roast = "";
  if(data.totalScore <= 15) roast = "Bro actually typed his CSS line-by-line. Respect! 👑";
  else if(data.totalScore <= 35) roast = "Mostly human, but I see you asking ChatGPT for Regex help. 🧐";
  else if(data.totalScore <= 55) roast = "A healthy mix of copy-paste and actual coding. Balanced! ⚖️";
  else if(data.totalScore <= 75) roast = "Vibe coded for sure! I bet v0 built this while you grabbed coffee. ☕";
  else roast = "Did you just tell AI 'make a website' and go to sleep? 💀";
  roastBox.textContent = `"${roast}"`;

  scoreGlow.style.backgroundColor = data.verdictColor;
  verdictEl.textContent = data.verdict;
  verdictEl.style.color = data.verdictColor;
  
  // Update Categories
  const catContainer = document.getElementById('categories-container');
  catContainer.innerHTML = '';
  
  const categories = [
    { key: 'meta', label: 'Meta Fingerprints' },
    { key: 'framework', label: 'Framework & CSS' },
    { key: 'cdn', label: 'CDN & Pipeline' },
    { key: 'quality', label: 'Code Quality' },
    { key: 'security', label: 'Security Flags' }
  ];
  
  let allFindingsForPrompt = [];
  
  categories.forEach(cat => {
    const catData = data.categories[cat.key];
    
    const catDiv = document.createElement('div');
    catDiv.className = 'category';
    
    const headerDiv = document.createElement('div');
    headerDiv.className = 'category-header';
    
    // Color code the badge
    let badgeColor = '#86efac';
    if(catData.score > 10) badgeColor = '#fca5a5';
    else if(catData.score > 5) badgeColor = '#fde047';
    
    headerDiv.innerHTML = `<span>${cat.label}</span><span class="cat-score-badge" style="color: ${badgeColor}">${catData.score}/20</span>`;
    catDiv.appendChild(headerDiv);
    
    catData.findings.forEach(f => {
      const p = document.createElement('p');
      p.className = `finding ${f.severity}`;
      
      // Determine dot color
      let dotColor = '#e2e8f0';
      if(f.severity === 'critical') dotColor = '#b91c1c';
      if(f.severity === 'high') dotColor = '#ef4444';
      if(f.severity === 'medium') dotColor = '#f97316';
      if(f.severity === 'low') dotColor = '#facc15';
      if(f.severity === 'clean') dotColor = '#10b981';
      
      p.style.setProperty('--dot-color', dotColor);
      p.textContent = f.text;
      catDiv.appendChild(p);
      
      if (f.severity !== 'clean' && f.severity !== 'info') {
        allFindingsForPrompt.push(`- ${f.text}`);
      }
    });
    
    catContainer.appendChild(catDiv);
  });
  
  // Add dot color css dynamic variable
  const style = document.createElement('style');
  style.innerHTML = '.finding::before { color: var(--dot-color); }';
  document.head.appendChild(style);
  
  // Generate Improvement Prompt
  const promptTextArea = document.getElementById('prompt-text');
  
  if (allFindingsForPrompt.length === 0) {
    promptTextArea.value = "The code looks great! No major AI-generation artifacts or security red flags were detected during the scan. Keep up the good work maintaining this codebase.";
  } else {
    let prompt = `I ran a "Vibe Code" security and architecture scan on this frontend code, and it flagged the following issues that indicate typical AI-generated shortcuts:\n\n`;
    prompt += allFindingsForPrompt.join('\n');
    prompt += `\n\nPlease act as a Senior Staff Engineer. Review the codebase and fix these specific issues. Refactor repetitive code, replace CDNs with proper package managers if applicable, fix accessibility issues, and ensure NO sensitive API keys or credentials are left exposed in the client-side code. Provide the updated, production-ready code.`;
    
    promptTextArea.value = prompt;
  }
}
