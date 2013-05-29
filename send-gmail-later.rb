# encoding utf-8
require 'gmail'

USERNAME = ENV['GOOGLE_USERNAME']
PASSWORD = ENV['GOOGLE_PASSWORD']

PATTERN = /^\[(\d+d)?(\d+h)?(\d+m)?\] */

Gmail.new(USERNAME, PASSWORD) do |gmail|
  now = DateTime.now

  gmail.mailbox('[Gmail]/Drafts').emails(:all).each do |draft|
    if draft.subject =~ PATTERN
      d = $1.to_i
      h = $2.to_i
      m = $3.to_i
      if d == 0 && h == 0 && m == 0
        next
      end

      send_date = draft.date + d + Rational(h * 60 + m, 1440)
      if send_date <= now
        gmail.deliver do
          to draft.to
          subject draft.subject.sub(PATTERN, '')
          body draft.body.decoded.encode('utf-8', draft.charset)
        end

        draft.date = now
        draft.archive!
      end
    end
  end
end
