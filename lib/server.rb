require 'rubygems'
require 'thin'

# TODO: automatically guess this value
APP_DIRECTORY = 'Build/Debug/test'

CUCUMBER_BUNDLE_DIR = File.join(File.dirname(__FILE__), 'Build', 'Debug', 'Cucumber')

MAIN_THREAD = Thread.current

class DeferrableBody
  include EventMachine::Deferrable

  def call(body)
    body.each do |chunk|
      @body_callback.call(chunk)
    end
  end

  def each(&blk)
    @body_callback = blk
  end
end

class CucumberAdapter
  AsyncResponse = [-1, {}, []].freeze
  
  def call(env)    
    if env['REQUEST_METHOD']=='GET'
      body = DeferrableBody.new
      
      # Get the headers out there asap, let the client know we're alive...
      EM.next_tick { env['async.callback'].call [200, {'Content-Type' => 'text/plain'}, body] }
      
      
      AsyncResponse
    else
      result = {:result => :ok}
      
      body = [result.to_json]
      [
        200,
        { 'Content-Type' => 'text/json' },
        body
      ]      
      MAIN_THREAD.wakeup
    end
  end
end

class CucumberIndexAdapter
  def call(env)
    html = File.read(File.join(APP_DIRECTORY, 'index.html'))
    
    html.gsub!(/<title>(.*)<\/title>/) do
      "<title>#{$1} - Cucumber</title>"
    end
    
    html.gsub!(/<\/body>/) do
      <<-END_OF_JS
        <script type="text/javascript">
            var cucumber = new CFBundle("/Cucumber/Bundle/");
            cucumber.load(true);
        </script>
      </body>
END_OF_JS
    end
    
    body = [html]
    [
      200,
      { 'Content-Type' => 'text/html' },
      body
    ]
  end
end

Thread.new{
  EM.run {
    cucumber = Rack::URLMap.new(
      '/cucumber' => CucumberAdapter.new,
      '/cucumber.html' => CucumberIndexAdapter.new,
      '/Cucumber/Bundle' => Rack::Directory.new(CUCUMBER_BUNDLE_DIR),
      '/' => Rack::Directory.new(APP_DIRECTORY)
    )
    
    Thin::Server.start('0.0.0.0', 3000) {
      run(cucumber)
      MAIN_THREAD.wakeup
    }
  }
}
Thread.stop

