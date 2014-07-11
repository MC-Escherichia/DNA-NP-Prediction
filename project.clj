(defproject edu.columbia.cheme.cris.Gavrog "1.0.0-SNAPSHOT" ; version "1.0.0-SNAPSHOT"
  ;; Beyond this point you may prepend a form with unquote, or ~, to eval it.

  ;;; Project Metadata
  ;; The description text is searchable from repositories like Clojars.
  :description "A clojurized version of Olaf Delgado-Friedrich's Systre, for using custom energy functions
               and hopefully to find new nanotechnological structures"
  :url "http://github.com/MC-Escherichia/gavrog"

  ;; The project's license. :distribution should be :repo or :manual;
  ;; :repo means it is OK for public repositories to host this project's
  ;; artifacts. A seq of :licenses is also supported.
  :license {:name "Eclipse Public License - v 1.0"
            :url "http://www.eclipse.org/legal/epl-v10.html"
            :distribution :repo
            :comments "same as Clojure"}
  ;; Warns users of earlier versions of Leiningen. Set this if your project
  ;; relies on features only found in newer Leiningen versions.
  :min-lein-version "2.0.0"

  ;;; Dependencies, Plugins, and Repositories
  ;; Dependencies are listed as [group-id/name version]; in addition
  ;; to keywords supported by Pomegranate, you can use :native-prefix
  ;; to specify a prefix. This prefix is used to extract natives in
  ;; jars that don't adhere to the default "<os>/<arch>/" layout that
  ;; Leiningen expects.
  :dependencies [[org.clojure/clojure "1.5.0"]
                 [criterium "0.4.2"]
                 [org.jogamp.gluegen/gluegen-rt-main "2.1.3"]
                 [org.jogamp.jogl/jogl-all-main "2.1.3"]
                 [local/jreality-native-deps "2014.01.15"]
                 [junit/junit "4.10"]
                 [xstream/xstream "1.2.2"]]

  :plugins [[lein-pprint "1.1.1"]
            [lein-idefiles "0.2.0"]
            [lein-junit "1.1.2"]]

                                        ;  :repositories
;  [["java.net" "http://download.ava.net/maven/2"]]
  ;; These repositories will be included with :repositories when loading plugins.
  ;; This would normally be set in a profile for non-public repositories.
  ;; All the options are the same as in the :repositories map.
  ;; repository. All settings supported in :repositories may be set here too.


  ;; You can set :update and :checksum policies here to have them
  ;; apply for all :repositories. Usually you will not set :update
  ;; directly but apply the "update" profile instead.
  :update :always

  :profiles {:dev {:dependencies [[junit/junit "4.11"]]}}

  ;;; Profiles
  ;; Each active profile gets merged into the project map. The :dev
  ;; and :user profiles are active by default, but the latter should be
  ;; looked up in ~/.lein/profiles.clj rather than set in project.clj.
  ;; Use the with-profiles higher-order task to run a task with a
  ;; different set of active profiles.
  ;; See `lein help profiles` for a detailed explanation.
                                        ; :profiles
  ;; Load these namespaces from within Leiningen to pick up hooks from them.

  ;;; Entry Point
  ;; The -main function in this namespace will be run at launch
  ;; (either via `lein run` or from an uberjar). It should be variadic:
  ;;
  ;; (ns my.service.runner
  ;;   (:gen-class))
  ;;
  ;; (defn -main
  ;;   "Application entry point"
  ;;   [& args]
  ;;   (comment Do app initialization here))
  ;;
  ;; This will be AOT compiled by default; to disable this, attach ^:skip-aot
  ;; metadata to the namespace symbol. ^:skip-aot will not disable AOT
  ;; compilation of :main when :aot is :all or contains the main class. It's
  ;; best to be explicit with the :aot key rather than relying on
  ;; auto-compilation of :main.
  :main org.gavrog.apps.systre.SystreGUI
  ;; Support project-specific task aliases. These are interpreted in
  ;; the same way as command-line arguments to the lein command. If
  ;; the alias points to a vector, it uses partial application. For
  ;; example, "lein with-magic run -m hi.core" would be equivalent to
  ;; "lein assoc :magic true run -m hi.core". Remember, commas are not
  ;; considered to be special by argument parsers, they're just part
  ;; of the preceding argument.
  :aliases {"launch" "run"
            "dumbrepl" ["trampoline" "run" "-m" "clojure.main/main"]
            ;; For complex aliases, a docstring may be attached. The docstring
            ;; will be printed instead of the expansion when running `lein help`.
            "test!" ^{:doc "Recompile sources and fetch deps before testing."}
            ;; Nested vectors are supported for the "do" task
            ["do" "clean" ["test" ":integration"] ["deploy" "clojars"]]}

  ;;; Running Project Code
  ;; Normally Leiningen runs the javac and compile tasks before
  ;; calling any eval-in-project code, but you can override this with
  ;; the :prep-tasks key to do other things like compile protocol buffers.
 ; :prep-tasks [["protobuf" "compile"] "javac" "compile"]
  ;; These namespaces will be AOT-compiled. Needed for gen-class and
  ;; other Java interop functionality. Put a regex here to compile all
  ;; namespaces whose names match. If you only need AOT for an uberjar
  ;; gen-class, put `:aot :all` in the :uberjar profile and see :target-path for
  ;; how to enable profile-baset target isolation.

  ;; Forms to prepend to every form that is evaluated inside your project.
  ;; Allows working around the Gilardi Scenario: http://technomancy.us/143
  :injections [(require 'clojure.pprint)
               (require 'clojure.repl)]
  ;; Java agents can instrument and intercept certain VM features. Include
  ;; :bootclasspath true to place the agent jar on the bootstrap classpath.
                                        ;  :java-agents [[nodisassemble "0.1.1" options "extra"]]
  ;; Options to pass to java compiler for java source,
  ;; exactly the same as command line arguments to javac.
                                        ; :javac-options ["-target" "1.6" "-source" "1.6" "-Xlint:-options"]
  ;; Sets the values of global vars within Clojure. This example
  ;; disables all pre- and post-conditions and emits warnings on
  ;; reflective calls. See the Clojure documentation for the list of
  ;; valid global variables to set (and their meaningful values).
  :global-vars {*warn-on-reflection* true
                *assert* false}
  ;; Use a different `java` executable for project JVMs. Leiningen's own JVM is
  ;; set with the LEIN_JAVA_CMD environment variable.
                                        ;:java-cmd "/home/phil/bin/java1.7"
  ;; You can set JVM-level options here. The :java-opts key is an alias for this.
  :jvm-opts ["-Xmx1g"
             "-Djava.awt.headless=false"]
  ;; Set the context in which your project code is evaluated. Defaults
  ;; to :subprocess, but can also be :leiningen (for plugins) or :nrepl
  ;; to connect to an existing project process over nREPL. A project nREPL
  ;; server can be started simply by invoking `lein repl`. If no connection
  ;; can be established, :nrepl falls back to :subprocess.
  :eval-in :leiningen
  ;; Enable bootclasspath optimization. This improves boot time but interferes
  ;; with certain libraries like Jetty that make assumptions about classloaders.
  :bootclasspath true

  ;;; Filesystem Paths
  ;; If you'd rather use a different directory structure, you can set these.
  ;; Paths that contain "inputs" are string vectors, "outputs" are strings.
  :source-paths ["src/clojure"]
  :java-source-paths ["src/java" ] ; Java source is stored separately.

  :junit ["test/java"]
  :test-paths ["test/java" ]
  :resource-paths ["resources"] ; Non-code files included in classpath/jar.
  ;; All generated files will be placed in :target-path. In order to avoid
  ;; cross-profile contamination (for instance, uberjar classes interfering
  ;; with development), it's recommended to include %s in in your custom
  ;; :target-path, which will splice in names of the currently active profiles.
  :target-path "target/%s/"
  ;; Directory in which to place AOT-compiled files. Including %s will
  ;; splice the :target-path into this value.
  :compile-path "%s/classy-files"
  ;; Directory in which to extract native components from inside dependencies.
  ;; Including %s will splice the :target-path into this value. Note that this
  ;; is not where to *look* for existing native libraries; use :jvm-opts with
  ;; -Djava.library.path=... instead for that.
  :native-path "%s"
  ;; Directories under which `lein clean` removes files.
  ;; Specified by keyword or keyword-chain to get-in path in this defproject.
  ;; Both a single path and a collection of paths are accepted as each.
  ;; For example, if the other parts of project are like:
  ;;   :target-path "target"
  ;;   :compile-path "classes"
  ;;   :foobar-paths ["foo" "bar"]
  ;;   :baz-config {:qux-path "qux"}
  ;; :clean-targets below lets `lein clean` remove files under "target",
  ;; "classes", "foo", "bar", "qux", and "out".
  :clean-targets [:target-path :compile-path
                  ]
  ;; Paths to include on the classpath from each project in the
  ;; checkouts/ directory. (See the FAQ in the Readme for more details
  ;; about checkout dependencies.) Set this to be a vector of
  ;; functions that take the target project as argument. Defaults to
  ;; [:source-paths :compile-path :resource-paths], but you could use
  ;; the following to share code from the test suite:


  ;;; Testing
  ;; Predicates to determine whether to run a test or not, take test metadata
  ;; as argument. See `lein help tutorial` for more information.

  ;; In order to support the `retest` task, Leiningen must monkeypatch the
  ;; clojure.test library. This disables that feature and breaks `lein retest`.
                                        ;  :monkeypatch-clojure-test false

  ;;; Repl
  ;; Options to change the way the REPL behaves.
  :repl-options {;; Specify the string to print when prompting for input.
                 ;; defaults to something like (fn [ns] (str *ns* "=> "))
                 :prompt (fn [ns] (str "your command for <" ns ">, master? " ))
                 ;; What to print when the repl session starts.
                 :welcome (println "Welcome to the magical world of the repl!")
                 ;; Specify the ns to start the REPL in (overrides :main in
                 ;; this case only)
                 :init-ns edu.columbia.cheme.cris.Gavrog
                 ;; This expression will run when first opening a REPL, in the
                 ;; namespace from :init-ns or :main if specified.
                 :init (println "here we are in" *ns*)
                 ;; Customize the socket the repl task listens on and
                 ;; attaches to.
         ;;        :host "0.2.2.2"
         ;;        :port 4001
                 ;; If nREPL takes too long to load it may timeout,
                 ;; increase this to wait longer before timing out.
                 ;; Defaults to 30000 (30 seconds)
                 :timeout 40000
                 ;; nREPL server customization
                 ;; Only one of #{:nrepl-handler :nrepl-middleware}
                 ;; may be used at a time.
                 ;; Use a different server-side nREPL handler.
                                        ; :nrepl-handler (clojure.tools.nrepl.server/default-handler)
                 ;; Add server-side middleware to nREPL stack.
                                        ;:nrepl-middleware [my.nrepl.thing/wrap-amazingness
                                        ;                   ;; TODO: link to more detailed documentation.
                                        ;                   ;; Middleware without appropriate metadata
                                        ;                   ;; (see clojure.tools.nrepl.middleware/set-descriptor!
                                        ;                   ;; for details) will simply be appended to the stack
                                        ;                   ;; of middleware (rather than ordered based on its
                                        ;                   ;; expectations and requirements).
                                        ;                   (fn [handler]
                                        ;                     (fn [& args]
                                        ;                       (prn :middle args)
                                        ;                       (apply handler args)))]
                 }

  ;;; Jar Output
  ;; Name of the jar file produced. Will be placed inside :target-path.
  ;; Including %s will splice the project version into the filename.
  :jar-name "gavrog2.jar"
  ;; As above, but for uberjar.
  :uberjar-name "gavrog2-standalone.jar"
  ;; Leave the contents of :source-paths out of jars (for AOT projects).
  :omit-source true
  ;; Files with names matching any of these patterns will be excluded from jars.
  :jar-exclusions [#"(?:^|/).svn/"]
  ;; Same thing, but for uberjars.
                                        ;  :uberjar-exclusions [#"ETA-INF/DUMMY.SF"]
  ;; Files to merge programmatically in uberjars when multiple same-named files
  ;; exist across project and dependencies.  Should be a map of filename strings
  ;; or regular expressions to a sequence of three functions:
  ;; 1. Takes an input stream; returns a parsed datum.
  ;; 2. Takes a new datum and the current result datum; returns a merged datum.
  ;; 3. Takes an output stream and a datum; writes the datum to the stream.
  ;; Resolved in reverse dependency order, starting with project.
  ;; Set arbitrary key/value pairs for the jar's manifest.


  )

;;; Environment Variables used by Leiningen

;; JAVA_CMD - executable to use for java(1)
;; JVM_OPTS - extra options to pass to the java command
;; DEBUG - increased verbosity
;; LEIN_HOME - directory in which to look for user settings
;; LEIN_SNAPSHOTS_IN_RELEASE - allow releases to depend on snapshots
;; LEIN_JVM_OPTS - tweak speed of plugins or fix compatibility with old Java versions
;; LEIN_REPL_HOST - interface on which to connect to nREPL server
;; LEIN_REPL_PORT - port on which to start or connect to nREPL server
;; LEIN_OFFLINE - equivalent of :offline? true but works for plugins
;; LEIN_GPG - gpg executable to use for encryption/signing
;; LEIN_NEW_UNIX_NEWLINES - ensure that `lein new` emits '\n' as newlines
;; LEIN_SUPPRESS_USER_LEVEL_REPO_WARNINGS - suppress "repository in user profile" warnings
;; LEIN_FAST_TRAMPOLINE - memoize `java` invocation command to speed up subsequent trampoline launches
;; http_proxy - host and port to proxy HTTP connections through
;; http_no_proxy - pipe-separated list of hosts which may be accessed directly11
