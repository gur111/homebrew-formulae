class Yabai < Formula
  desc "A tiling window manager for macOS based on binary space partitioning."
  homepage "https://github.com/gur111/yabai"
  url "https://github.com/gur111/yabai/releases/download/v5.0.2/yabai-v5.0.2.tar.gz"
  sha256 "981044e0339ba64b41ff9149d8e6fad4bfc0b7cc88df042754742f9e214bfe50"
  head "https://github.com/gur111/yabai.git"

  depends_on :macos => :big_sur

  def install
    (var/"log/yabai").mkpath
    man.mkpath

    if build.head?
      system "make", "-j1", "install"
    end

    bin.install "#{buildpath}/bin/yabai"
    (pkgshare/"examples").install "#{buildpath}/examples/yabairc"
    (pkgshare/"examples").install "#{buildpath}/examples/skhdrc"
    man1.install "#{buildpath}/doc/yabai.1"
  end

  def caveats; <<~EOS
    Copy the example configuration into your home directory:
      cp #{opt_pkgshare}/examples/yabairc ~/.yabairc
      cp #{opt_pkgshare}/examples/skhdrc ~/.skhdrc

    Logs will be found in
      #{var}/log/yabai/yabai.[out|err].log

    If you are using the scripting-addition; remember to update your sudoers file:
      sudo visudo -f /private/etc/sudoers.d/yabai

    Build the configuration row by running:
      echo "$(whoami) ALL=(root) NOPASSWD: sha256:$(shasum -a 256 $(which yabai) | cut -d " " -f 1) $(which yabai) --load-sa"

    README: https://github.com/gur111/yabai/wiki/Installing-yabai-(latest-release)#configure-scripting-addition
    EOS
  end

  plist_options :manual => "yabai"

  def plist; <<~EOS
    <?xml version="1.0" encoding="UTF-8"?>
    <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
    <plist version="1.0">
    <dict>
      <key>Label</key>
      <string>#{plist_name}</string>
      <key>ProgramArguments</key>
      <array>
        <string>#{opt_bin}/yabai</string>
      </array>
      <key>EnvironmentVariables</key>
      <dict>
        <key>PATH</key>
        <string>#{HOMEBREW_PREFIX}/bin:/usr/bin:/bin:/usr/sbin:/sbin</string>
      </dict>
      <key>RunAtLoad</key>
      <true/>
      <key>KeepAlive</key>
      <true/>
      <key>ThrottleInterval</key>
      <integer>30</integer>
      <key>StandardOutPath</key>
      <string>#{var}/log/yabai/yabai.out.log</string>
      <key>StandardErrorPath</key>
      <string>#{var}/log/yabai/yabai.err.log</string>
      <key>ProcessType</key>
      <string>Interactive</string>
      <key>Nice</key>
      <integer>-20</integer>
    </dict>
    </plist>
    EOS
  end

  test do
    assert_match "yabai-v#{version}", shell_output("#{bin}/yabai --version")
  end
end
