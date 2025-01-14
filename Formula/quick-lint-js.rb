class QuickLintJs < Formula
  desc "Find bugs in your JavaScript code"
  homepage "https://quick-lint-js.com/"
  url "https://c.quick-lint-js.com/releases/2.4.2/source/quick-lint-js-2.4.2.tar.gz"
  sha256 "c52f961669439ae13e9676d471118f995baf46279da70ac0a7c98c4aede925fd"
  license "GPL-3.0-or-later"
  revision 1
  head "https://github.com/quick-lint/quick-lint-js.git", branch: "master"

  bottle do
    sha256 cellar: :any,                 arm64_monterey: "b44001ea2edb8e03eeb893f8f058a269b41831146057990b282d002b3e3e0029"
    sha256 cellar: :any,                 arm64_big_sur:  "583de790c3199885d996f8e1cc8ad6baaa172dce11001fae10c4d54a8560fc85"
    sha256 cellar: :any,                 monterey:       "fa7a70b2fa8bcf80a8e9a2e4e285f0394edeb2a7494212f352824482f7495aba"
    sha256 cellar: :any,                 big_sur:        "92e002c03fcc14372899c246f74dc849bf8206803cb23de1a809558994f8d3dc"
    sha256 cellar: :any,                 catalina:       "21903b2719081c1a79d8f12f59473795dcd732ab11bd7814cb530293f2c0cf5b"
    sha256 cellar: :any_skip_relocation, x86_64_linux:   "61ac5a56ad923677b0a8983ce548c900a8d0ace8c951140101cffe4289406829"
  end

  depends_on "cmake" => :build
  depends_on "googletest" => :build
  depends_on "pkg-config" => :build
  depends_on "boost"
  depends_on "simdjson"

  on_linux do
    # Use Homebrew's C++ compiler in case the host's C++
    # compiler is too old.
    depends_on "gcc"
  end

  # quick-lint-js requires some C++17 features, thus
  # requires GCC 8 or newer.
  fails_with gcc: "5"
  fails_with gcc: "6"
  fails_with gcc: "7"

  def install
    system "cmake", "-S", ".", "-B", "build",
                    "-DBUILD_TESTING=ON",
                    "-DQUICK_LINT_JS_ENABLE_BENCHMARKS=OFF",
                    "-DQUICK_LINT_JS_INSTALL_EMACS_DIR=#{elisp}",
                    "-DQUICK_LINT_JS_INSTALL_VIM_NEOVIM_TAGS=ON",
                    "-DQUICK_LINT_JS_USE_BUNDLED_BOOST=OFF",
                    "-DQUICK_LINT_JS_USE_BUNDLED_GOOGLE_BENCHMARK=OFF",
                    "-DQUICK_LINT_JS_USE_BUNDLED_GOOGLE_TEST=OFF",
                    "-DQUICK_LINT_JS_USE_BUNDLED_SIMDJSON=OFF",
                    *std_cmake_args
    system "cmake", "--build", "build"
    chdir "build" do
      system "ctest", "-V"
    end
    system "cmake", "--install", "build"
  end

  test do
    (testpath/"errors.js").write <<~EOF
      const x = 3;
      const x = 4;
    EOF
    ohai "#{bin}/quick-lint-js errors.js"
    output = `#{bin}/quick-lint-js errors.js 2>&1`
    puts output
    refute_equal $CHILD_STATUS.exitstatus, 0
    assert_match "E0034", output

    (testpath/"no-errors.js").write 'console.log("hello, world!");'
    assert_empty shell_output("#{bin}/quick-lint-js no-errors.js")
  end
end
