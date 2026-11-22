class Granted < Formula
  desc "Easiest way to access your cloud"
  homepage "https://granted.dev/"
  version "0.40.0"
  license "MIT"

  # Prebuilt release binaries.
  on_macos do
    on_arm do
      url "https://releases.granted.dev/granted/v0.40.0/granted_0.40.0_darwin_arm64.tar.gz"
      sha256 "55d2848b914f1ccf3c16f76630cd9679030a82f5110afe74d0ebb91287cdab8c"
    end
    on_intel do
      url "https://releases.granted.dev/granted/v0.40.0/granted_0.40.0_darwin_x86_64.tar.gz"
      sha256 "36fc177120d23c429aa602e81772578ab7e3e07373b6fa13e6f4d477660af515"
    end
  end

  on_linux do
    on_arm do
      url "https://releases.granted.dev/granted/v0.40.0/granted_0.40.0_linux_arm64.tar.gz"
      sha256 "0da965ca9b8200ce75794be246677a2f15909a9a87db89a9dc512aecee09a55d"
    end
    on_intel do
      url "https://releases.granted.dev/granted/v0.40.0/granted_0.40.0_linux_x86_64.tar.gz"
      sha256 "c55e2ccaf60ed810b5d389f558c9a48a35b356375d7fe6666b19b98695eda794"
    end
  end

  # The release archives don't include the tcsh script yet.
  resource "assume.tcsh" do
    url "https://raw.githubusercontent.com/fwdcloudsec/granted/v0.40.0/scripts/assume.tcsh"
    sha256 "6fecd757a9798ad19589d9083d9f828b491d473fa554b6a9c58b47f8083f8d60"
  end

  def install
    bin.install "granted"
    # a symlink, not a separate binary, so both names share the same Keychain access
    bin.install_symlink "granted" => "assumego"
    # these must be in bin, and not sourced automatically
    bin.install "assume"
    bin.install "assume.fish"
    resource("assume.tcsh").stage { bin.install "assume.tcsh" }
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
        alias assume "source `brew --prefix`/bin/assume.tcsh"
    EOS
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/granted --version")

    ENV["XDG_CONFIG_HOME"] = testpath
    output = shell_output("#{bin}/granted registry add 2>&1", 1)
    assert_match "[✘] Required flags \"name, url\" not set", output

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
