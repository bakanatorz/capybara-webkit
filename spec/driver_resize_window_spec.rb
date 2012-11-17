require 'spec_helper'
require 'capybara/webkit/driver'

describe Capybara::Webkit::Driver, "#resize_window(width, height)" do

  before(:all) do
    app = lambda do |env|
      body = <<-HTML
        <html>
          <body>
            <h1 id="dimentions">UNKNOWN</h1>

            <script>
              window.onload = window.onresize = function(){
                document.getElementById("dimentions").innerHTML = "[" + window.innerWidth + "x" + window.innerHeight + "]";
              };
            </script>

          </body>
        </html>
      HTML

      [
        200,
        { 'Content-Type' => 'text/html', 'Content-Length' => body.length.to_s },
        [body]
      ]
    end

    @driver = Capybara::Webkit::Driver.new(app, :browser => $webkit_browser)
  end

  DEFAULT_DIMENTIONS = "[1680x1050]"

  it "resizes the window to the specified size" do
    @driver.visit("/")

    @driver.resize_window(800, 600)
    @driver.html.should include("[800x600]")

    @driver.resize_window(300, 100)
    @driver.html.should include("[300x100]")
  end

  it "resizes the window to the specified size even before the document has loaded" do
    @driver.resize_window(800, 600)
    @driver.visit("/")
    @driver.html.should include("[800x600]")
  end

  it "resets the window to the default size when the driver is reset" do
    @driver.resize_window(800, 600)
    @driver.reset!
    @driver.visit("/")
    @driver.html.should include(DEFAULT_DIMENTIONS)
  end

  after(:all) { @driver.reset! }
end
