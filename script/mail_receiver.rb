# default rails environment to development
Rails.env ||= 'development'
# require rails environment file which basically "boots" up rails for this script
require File.join(File.dirname(__FILE__), '..', 'config', 'environment')
require 'net/imap'
require 'net/http'

# amount of time to sleep after each loop below
# Dreamhost Dovecote should be able to loop every 5-10 seconds
SLEEP_TIME = 60

# mail.yml is the imap config for the email account (ie: username, host, etc.) -- add this later,
# RAILS_ROOT is pre Rails 3
#config = YAML.load(File.read(File.join(Rails.root, 'config', 'mail.yml')))

# this script will continue running forever
loop do
  begin
    # make a connection to imap account
    imap = Net::IMAP.new('mail.dabneywest.com')
    imap.login(join@dabneywest.com, ricketts)
    # select inbox as our mailbox to process
    imap.select('Inbox')

    # get all emails that are in inbox that have not been deleted
    imap.uid_search(["NOT", "DELETED"]).each do |uid|
      # fetches the straight up source of the email for tmail to parse
      source   = imap.uid_fetch(uid, ['RFC822']).first.attr['RFC822']

      # Mailthread#new_from_email accepts the source and creates new location
      mailthread = Mailthread.new_from_email(source)

      # check for an existing location that matches the one created from email source
      existing = Mailthread.existing_thread(mailthread)

      if existing
        # location exists so update the sign color to the emailed location
        existing.title = Mailthread.title
        if existing.save
          # existing location was updated
        else
          # existing location was invalid
        end
      elsif mailthread.save
        # emailed location was valid and created
      else
        # emailed location was invalid
      end

      # there isn't move in imap so we copy to database and then delete from inbox
      #imap.
      imap.uid_store(uid, "+FLAGS", [:Deleted])
    end

    # expunge removes the deleted emails
    imap.expunge
    imap.logout
    imap.disconnect

      # NoResponseError and ByResponseError happen often when imap'ing
  rescue Net::IMAP::NoResponseError => e
    # send to log file, db, or email
  rescue Net::IMAP::ByeResponseError => e
    # send to log file, db, or email
  rescue => e
    # send to log file, db, or email
  end

  # sleep for SLEEP_TIME and then do it all over again
  sleep(SLEEP_TIME)
end