

class Mailthread < ActiveRecord::Base
  # attr_accessible :title, :body
  #mailthreads is what was specified as threads - to avoid conflict with Ruby namespace


    def self.new_from_email(source)
      attrs, email = {}, Mail.read(source)
      # set title attribute equal to subject in proper form
      attrs[:title]   = email.subject.blank? ? '' : email.subject.downcase.strip.titleize
      # set body equal to the body with email signatures stripped
      attrs[:body]  = parse_address(email.body)
      # create new location from the attributes
      new(attrs)
    end

    def self.parse_address(body)
      body.split("\n\n").first
    end

end
