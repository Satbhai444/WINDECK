import os

with open(r"D:\WINDECK\Premium_Desktop_Presentation.html", "r", encoding="utf-8") as f:
    html = f.read()

# Replace the text about it being open-source
html = html.replace(
    "Both the Windows Server and the Android Application are open-source and available to download directly from the official GitHub repository.",
    "Both the Windows Server and the Android Application are available to download directly from the official WinDeck website."
)

# Replace the "View Repository" button with "Visit Website" button
html = html.replace(
    "<a href='https://github.com/Satbhai444/WINDECK' target='_blank' class='inline-flex items-center justify-center gap-2 bg-slate-800 hover:bg-slate-700 text-white py-3 px-6 rounded-lg font-medium transition-colors border border-slate-600 w-full mb-3 md:mb-4'>\n                                    <svg class='w-5 h-5' fill='currentColor' viewBox='0 0 24 24'><path fill-rule='evenodd' d='M12 2C6.477 2 2 6.484 2 12.017c0 4.425 2.865 8.18 6.839 9.504.5.092.682-.217.682-.483 0-.237-.008-.868-.013-1.703-2.782.605-3.369-1.343-3.369-1.343-.454-1.158-1.11-1.466-1.11-1.466-.908-.62.069-.608.069-.608 1.003.07 1.531 1.032 1.531 1.032.892 1.53 2.341 1.088 2.91.832.092-.647.35-1.088.636-1.338-2.22-.253-4.555-1.113-4.555-4.951 0-1.093.39-1.988 1.029-2.688-.103-.253-.446-1.272.098-2.65 0 0 .84-.27 2.75 1.026A9.564 9.564 0 0112 6.844c.85.004 1.705.115 2.504.337 1.909-1.296 2.747-1.027 2.747-1.027.546 1.379.202 2.398.1 2.651.64.7 1.028 1.595 1.028 2.688 0 3.848-2.339 4.695-4.566 4.943.359.309.678.92.678 1.855 0 1.338-.012 2.419-.012 2.747 0 .268.18.58.688.482A10.019 10.019 0 0022 12.017C22 6.484 17.522 2 12 2z' clip-rule='evenodd'></path></svg>\n                                    View Repository\n                                </a>",
    "<a href='https://website-fawn-nine-99.vercel.app' target='_blank' class='inline-flex items-center justify-center gap-2 bg-blue-600 hover:bg-blue-500 text-white py-3 px-6 rounded-lg font-medium transition-colors border border-blue-500 w-full mb-3 md:mb-4'>\n                                    <svg class='w-5 h-5' fill='none' stroke='currentColor' viewBox='0 0 24 24'><path stroke-linecap='round' stroke-linejoin='round' stroke-width='2' d='M4 16v1a3 3 0 003 3h10a3 3 0 003-3v-1m-4-4l-4 4m0 0l-4-4m4 4V4'></path></svg>\n                                    Download App\n                                </a>"
)

# Remove the "give it a star" text
html = html.replace(
    "<p class='text-xs md:text-sm text-blue-400 font-medium text-center'>\n                                    If you like the project, please consider giving it a star!\n                                </p>",
    ""
)

with open(r"D:\WINDECK\Premium_Desktop_Presentation.html", "w", encoding="utf-8") as f:
    f.write(html)
