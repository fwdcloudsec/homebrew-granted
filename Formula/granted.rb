class Granted < Formula
  desc "Easiest way to access your cloud"
  homepage "https://granted.dev/"
  url "https://github.com/fwdcloudsec/granted/archive/refs/tags/v0.38.0.tar.gz"
  sha256 "b6e2bc8fda38f55ee4673cc0f3f762e076d2029df1d9a8552681a2aacce88721"
  license "MIT"
  head "https://github.com/fwdcloudsec/granted.git", branch: "main"

  depends_on "go" => :build

  def install
    ldflags = %W[
      -s -w
      -X github.com/fwdcloudsec/granted/internal/build.Version=#{version}
      -X github.com/fwdcloudsec/granted/internal/build.ConfigFolderName=.granted
    ]

    system "go", "build", *std_go_args(ldflags:), "./cmd/granted"
    bin.install_symlink "granted" => "assumego"
    # these must be in bin, and not sourced automatically
    bin.install "scripts/assume"
    bin.install "scripts/assume.fish"
    bin.install "scripts/assume.tcsh"
  end

  def caveats
    <<~EOS
      To use Granted, you need to configure your shell.

      For bash, add to ~/.bashrc or ~/.bash_profile:
        alias assume="source $(brew --prefix)/bin/assume"

      For zsh, add to ~/.zshrc:
        alias assume="source $(brew --prefix)/bin/assume"

      For fish, add to ~/.config/fish/config.fish:
        alias assume="source $(brew --prefix)/bin/assume.fish"

      For tcsh, add to ~/.tcshrc:
        alias assume "source $(brew --prefix)/bin/assume.tcsh"
    EOS
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/granted --version")

    output = shell_output("#{bin}/granted auth configure 2>&1", 1)
    assert_match "[✘] please provide a url argument", output

    ENV["GRANTED_ALIAS_CONFIGURED"] = "true"
    assert_match version.to_s, shell_output("#{bin}/assume --version")
    assert_match version.to_s, shell_output("#{bin}/assumego --version")

    # assume is interactive; pipe_output provides empty stdin causing prompts to fail.
    # Match varies by environment: "does not match" (with browser), "Could not find
    # default browser" (no browser configured), or "EOF" (when stdin closes).
    output = pipe_output("#{bin}/assume non-existing-role 2>&1", "")
    assert_match(/does not match any profiles|Could not find default browser|EOF/, output)
  end
end
