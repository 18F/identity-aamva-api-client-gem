module Aamva
  module Util
    class << self
      def fetch_env(key, *default)
        env.fetch(key.downcase, *default)
      end

      private

      def env
        Hash[ENV.map { |key, value| [key.downcase, value] }]
      end
    end
  end
end
