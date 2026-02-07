#!/usr/bin/env ruby
# frozen_string_literal: true

# Simple Court Reserve SAVE Button Clicker
#
# Setup:
#   1) bundle install
#   2) cp .env.example .env and set CLICK_TIME
#   3) Open Chrome, navigate to booking page, log in, open booking modal
#   4) bundle exec ruby court-booker/court-booker.rb
#   5) Script waits until CLICK_TIME, then clicks SAVE button
#

require "dotenv/load"
require "time"

CLICK_TIME = ARGV[0]
CLICK_X = ENV["CLICK_X"] # X coordinate (optional)
CLICK_Y = ENV["CLICK_Y"] # Y coordinate (optional)
CLICK_OFFSET_NS = (ENV["CLICK_OFFSET_NS"] || "0").to_i
CLICK_URL = ENV["CLICK_URL"] || "https://usta.courtreserve.com/Online/Reservations/Bookings/5881?sId=294"

unless CLICK_TIME
  warn "Usage: bundle exec ruby court-booker/court-booker.rb 'YYYY-MM-DD HH:MM:SS'"
  warn "Example: bundle exec ruby court-booker/court-booker.rb '2026-02-07 13:30:00'"
  warn ""
  warn "To find coordinates:"
  warn "  1. Press Cmd+Shift+4 (screenshot tool)"
  warn "  2. Hover over SAVE button and note the X,Y coordinates shown"
  warn "  3. Press ESC to cancel screenshot"
  warn "  4. Set CLICK_X and CLICK_Y in .env"
  exit 1
end

def format_time(time)
  time.strftime("%Y-%m-%d %H:%M:%S.%9N")
end

def delta_ns(target_time, actual_time)
  ((actual_time.to_f - target_time.to_f) * 1_000_000_000).round
end

def click_save_button(target_time)
  # Activate Chrome right before the click (no artificial delay)
  system("osascript", "-e", 'tell application "Google Chrome" to activate')

  if ENV["CLICK_X"] && ENV["CLICK_Y"]
    x = ENV["CLICK_X"]
    y = ENV["CLICK_Y"]
    puts "\n[#{format_time(Time.now)}] Moving mouse to (#{x}, #{y}) and clicking..."

    # Try using cliclick if available, otherwise fall back to AppleScript
    if system("which cliclick > /dev/null 2>&1")
      system("cliclick", "c:#{x},#{y}")
    else
      applescript = %{
        tell application "System Events"
          set mouseLoc to {#{x}, #{y}}
          do shell script "osascript -e 'tell application \\"System Events\\" to set position of mouse to {#{x}, #{y}}' 2>/dev/null || true"
          delay 0.005
          do shell script "osascript -e 'tell application \\"System Events\\" to click at {#{x}, #{y}}' 2>/dev/null || true"
        end tell
      }
      system("osascript", "-e", applescript)
    end
  else
    puts "\n[#{format_time(Time.now)}] Clicking at current mouse position..."

    applescript = %{
      tell application "System Events"
        click at (current position of mouse)
      end tell
    }

    system("osascript", "-e", applescript)
  end

  clicked_at = Time.now
  puts "[#{format_time(clicked_at)}] ✓ Click sent! (Δ #{delta_ns(target_time, clicked_at)} ns)"
end

target_time = Time.parse(CLICK_TIME) - (CLICK_OFFSET_NS / 1_000_000_000.0)
now = Time.now
puts "[#{format_time(now)}] Target time (offset #{CLICK_OFFSET_NS} ns): #{format_time(target_time)}"
puts "[#{format_time(now)}] Current time: #{format_time(now)}"
puts "[#{format_time(now)}] Countdown started..."
puts ""

activated = false

loop do
  now = Time.now
  remaining = target_time - now

  if !activated && remaining <= 0.5
    system("osascript", "-e", 'tell application "Google Chrome" to activate')
    activated = true
    puts "\n[#{format_time(Time.now)}] Chrome activated (pre-click)"
  end

  if remaining <= 0
    puts "\n[#{format_time(Time.now)}] 🎯 CLICK TIME REACHED!"
    click_save_button(target_time)
    break
  end

  hours = (remaining / 3600).floor
  minutes = ((remaining % 3600) / 60).floor
  seconds = (remaining % 60).floor
  millis = ((remaining % 1) * 1000).floor

  printf "[%s] ⏱️  %02d:%02d:%02d.%03d remaining\r", format_time(Time.now), hours, minutes, seconds, millis
  $stdout.flush

  if remaining > 0.5
    sleep(0.1)
  elsif remaining > 0.05
    sleep(0.01)
  elsif remaining > 0.005
    sleep(0.001)
  else
    # Busy-wait the last few milliseconds for max precision
    while Time.now < target_time
    end
  end
end
