#!/usr/bin/env ruby
# frozen_string_literal: true

# Precision mouse click automation that waits until a specific timestamp
# and performs a click at specified coordinates.

require "dotenv/load"
require "time"

CLICK_X = ENV["CLICK_X"]
CLICK_Y = ENV["CLICK_Y"]
CLICK_OFFSET_NS = (ENV["CLICK_OFFSET_NS"] || "0").to_i
DEBUG_MODE = ARGV.include?("--debug")
CLICK_TIME = DEBUG_MODE ? nil : ARGV[0]
CLICLICK_AVAILABLE = system("which cliclick > /dev/null 2>&1")
DEBUG_DELAY_S = 2

def show_usage_and_exit
  warn "Usage: bundle exec ruby click-at/click-at.rb 'YYYY-MM-DD HH:MM:SS'"
  warn "       bundle exec ruby click-at/click-at.rb --debug"
  warn ""
  warn "Example: bundle exec ruby click-at/click-at.rb '2026-02-07 13:30:00'"
  warn "Debug:   bundle exec ruby click-at/click-at.rb --debug  (clicks #{DEBUG_DELAY_S}s from now)"
  warn ""
  warn "To find coordinates:"
  warn "  1. Press Cmd+Shift+4 (screenshot tool)"
  warn "  2. Hover over target button and note the X,Y coordinates shown"
  warn "  3. Press ESC to cancel screenshot"
  warn "  4. Set CLICK_X and CLICK_Y in .env"
  warn ""
  warn "Optional: Set CLICK_OFFSET_NS in .env to adjust click timing (e.g. 228494167 for 228 ms)"
  exit 1
end

def format_time(time)
  time.strftime("%Y-%m-%d %H:%M:%S.%9N")
end

def log(message)
  puts "[#{format_time(Time.now)}] #{message}"
end

def perform_click(target_time)
  if CLICLICK_AVAILABLE
    system("cliclick", "c:#{CLICK_X},#{CLICK_Y}")
  else
    applescript = %{
      tell application "System Events"
        do shell script "osascript -e 'tell application \\"System Events\\" to set position of mouse to {#{CLICK_X}, #{CLICK_Y}}' 2>/dev/null || true"
        delay 0.005
        do shell script "osascript -e 'tell application \\"System Events\\" to click at {#{CLICK_X}, #{CLICK_Y}}' 2>/dev/null || true"
      end tell
    }
    system("osascript", "-e", applescript)
  end
  log "Click sent! (Δ #{((Time.now.to_f - target_time.to_f) * 1_000_000_000).round} ns)"
  puts "[#{format_time(target_time)}] Target time"
end

def format_countdown(remaining)
  "%02d:%02d:%02d.%09d" % [
    (remaining / 3600).floor,               # Hours
    ((remaining % 3600) / 60).floor,        # Minutes
    (remaining % 60).floor,                 # Seconds
    (remaining % 1 * 1_000_000_000).floor   # Nanoseconds
  ]
end

def adaptive_sleep(remaining)
  if remaining > 0.5
    sleep(0.1)
  elsif remaining > 0.05
    sleep(0.01)
  elsif remaining > 0.005
    sleep(0.001)
  else
    while Time.now < @target_time
    end
  end
end

def wait_until_target_time(target_time)
  log "Target time (offset #{CLICK_OFFSET_NS} ns): #{format_time(target_time)}"
  log "Current time: #{format_time(Time.now)}"
  log "Countdown started..."
  puts ""
  
  switch_to_chrome = false
  
  loop do
    now = Time.now
    remaining = target_time - now
    
    if !switch_to_chrome && remaining <= 0.5
      system("osascript", "-e", 'tell application "Google Chrome" to activate')
      switch_to_chrome = true
      log "Switched to Chrome to prepare for clicking at [#{CLICK_X}, #{CLICK_Y}]"
    end
    
    return if remaining <= 0
    
    printf "[%s] ⏱️  %s remaining\r", format_time(now), format_countdown(remaining)
    $stdout.flush
    
    adaptive_sleep(remaining)
  end
end

show_usage_and_exit unless (CLICK_TIME || DEBUG_MODE) && CLICK_X && CLICK_Y

@target_time = if DEBUG_MODE
                 (Time.now + DEBUG_DELAY_S).ceil
               else
                 Time.parse(CLICK_TIME) - (CLICK_OFFSET_NS / 1_000_000_000.0)
               end

wait_until_target_time(@target_time)
perform_click(@target_time)
