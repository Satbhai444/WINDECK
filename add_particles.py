import os

with open(r"D:\WINDECK\Premium_Desktop_Presentation.html", "r", encoding="utf-8") as f:
    html = f.read()

html = html.replace(".bg-pattern { background-image: radial-gradient(rgba(51, 65, 85, 0.2) 1px, transparent 1px); background-size: 24px 24px; }", "#particles-js { position: fixed; width: 100vw; height: 100vh; top: 0; left: 0; z-index: -2; pointer-events: none; }")

html = html.replace("<body class='bg-pattern'>", "<body>\n    <div id='particles-js'></div>")

scripts = """
    <script src='https://cdn.jsdelivr.net/particles.js/2.0.0/particles.min.js'></script>
    <script>
        particlesJS('particles-js', {
          "particles": {
            "number": { "value": 50, "density": { "enable": true, "value_area": 800 } },
            "color": { "value": "#3b82f6" },
            "shape": { "type": "circle" },
            "opacity": { "value": 0.3, "random": false },
            "size": { "value": 3, "random": true },
            "line_linked": { "enable": true, "distance": 150, "color": "#3b82f6", "opacity": 0.2, "width": 1 },
            "move": { "enable": true, "speed": 1.5, "direction": "none", "random": false, "straight": false, "out_mode": "out", "bounce": false }
          },
          "interactivity": {
            "detect_on": "canvas",
            "events": { "onhover": { "enable": true, "mode": "grab" }, "onclick": { "enable": false }, "resize": true },
            "modes": { "grab": { "distance": 140, "line_linked": { "opacity": 0.5 } } }
          },
          "retina_detect": true
        });
    </script>
</body>
"""

html = html.replace("</body>", scripts)

with open(r"D:\WINDECK\Premium_Desktop_Presentation.html", "w", encoding="utf-8") as f:
    f.write(html)
