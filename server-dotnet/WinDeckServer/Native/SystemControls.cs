using System;
using System.Runtime.InteropServices;
using System.Diagnostics;
using System.Management;

namespace WinDeckServer.Native
{
    public static class SystemControls
    {
        [DllImport("user32.dll")]
        public static extern void mouse_event(uint dwFlags, int dx, int dy, uint dwData, int dwExtraInfo);
        
        [DllImport("user32.dll")]
        public static extern bool GetCursorPos(out POINT lpPoint);
        
        [DllImport("user32.dll")]
        public static extern bool SetCursorPos(int X, int Y);
        
        [DllImport("user32.dll")]
        public static extern void keybd_event(byte bVk, byte bScan, uint dwFlags, int dwExtraInfo);

        public struct POINT { public int X; public int Y; }
        public const uint LEFTDOWN = 0x02;
        public const uint LEFTUP = 0x04;
        public const uint RIGHTDOWN = 0x08;
        public const uint RIGHTUP = 0x10;
        public const uint WHEEL = 0x0800;

        public static void MoveMouse(int dx, int dy)
        {
            if (GetCursorPos(out POINT p))
            {
                SetCursorPos(p.X + dx, p.Y + dy);
            }
        }

        public static void ClickMouse(string button = "left")
        {
            if (button == "left")
            {
                mouse_event(LEFTDOWN, 0, 0, 0, 0);
                mouse_event(LEFTUP, 0, 0, 0, 0);
            }
            else if (button == "right")
            {
                mouse_event(RIGHTDOWN, 0, 0, 0, 0);
                mouse_event(RIGHTUP, 0, 0, 0, 0);
            }
        }

        public static void ScrollMouse(int deltaY)
        {
            mouse_event(WHEEL, 0, 0, (uint)deltaY, 0);
        }

        public static void SendKey(byte vkCode)
        {
            keybd_event(vkCode, 0, 1, 0); // KEYEVENTF_EXTENDEDKEY
            keybd_event(vkCode, 0, 3, 0); // KEYEVENTF_EXTENDEDKEY | KEYEVENTF_KEYUP
        }

        public static void ExecuteAction(string action)
        {
            switch (action)
            {
                case "volume-up":
                    SendKey(175);
                    break;
                case "volume-down":
                    SendKey(174);
                    break;
                case "mute":
                    SendKey(173);
                    break;
                case "media-play-pause":
                    SendKey(179);
                    break;
                case "media-next":
                    SendKey(176);
                    break;
                case "media-prev":
                    SendKey(177);
                    break;
                case "lock":
                    Process.Start("rundll32.exe", "user32.dll,LockWorkStation");
                    break;
                case "sleep":
                    Process.Start("rundll32.exe", "powrprof.dll,SetSuspendState 0,1,0");
                    break;
            }
        }
    }
}
