import os

with open(r"D:\WINDECK\VibeCodeDetector\popup.js", "r", encoding="utf-8") as f:
    js = f.read()

# Update the displayResults function to animate the SVG ring and set correct colors
new_display_results = """
function displayResults(data) {
  const resultsContainer = document.getElementById('results-container');
  resultsContainer.style.display = 'block';
  
  // Update Score Card
  const scoreValue = document.getElementById('score-value');
  const verdictEl = document.getElementById('verdict');
  const circleProgress = document.getElementById('circle-progress');
  const scoreGlow = document.getElementById('score-glow');
  
  // Animate numbers
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
"""

js = js.split("function displayResults(data) {")[0] + new_display_results

with open(r"D:\WINDECK\VibeCodeDetector\popup.js", "w", encoding="utf-8") as f:
    f.write(js)
