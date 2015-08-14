require 'gpgme'
	
class TextProcessor
	def self.process(string, args={})
		onramp(string)
		operate
		offramp
	end
end

class ViewProcessor < TextProcessor
	def self.onramp(string)
		@separator = string[ /-{20,}\n/ ]
		sepat = string.index(@separator)
		@head = string[0 .. sepat - 1]
		@body = string[sepat + @separator.length .. -1]
	end
	def self.operate
		msgsep = pgpseparators('PGP MESSAGE')
		crypto = GPGME::Crypto.new
		@body.gsub!( /#{Regexp.quote(msgsep[0])}.*#{Regexp.quote(msgsep[1])}/m ) { |ciphertext|
			# do any necessary processing of the ciphertext
			extraheaders = "- encrypted\n"
			# TODO: catch exceptions when decryption fails
			plaindata = crypto.decrypt ciphertext do |signature|
				#puts signature
			end
			@head += extraheaders
			plaindata.to_s
		}
	end
	def self.offramp
		@head + @separator + @body
	end

	private

	def self.pgpseparators(type)
		["-----BEGIN " + type + "-----\n", "-----END " + type + "-----\n"]
	end
end
