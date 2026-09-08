# Lab 01 — Configure the toolchain and build a project

**Duration:** 90 min · **Objectives:** JCF-K1

## Objectives

After this lab, learners can:

- Verify a consistent JDK across the shell, Maven and the IDE.
- Create a Maven project that compiles, tests, packages and runs.
- Read `pom.xml` and set dependency scopes deliberately.

## Before you start

- You have read [Development Environment & the Java Toolchain](toolchain-and-build.md).
- A JDK 21 and Maven 3.9 are installed.
- You have a Git repository for this module.

## Steps

1. **Prove the toolchain agrees.** Capture the output of all four into `docs/toolchain.txt`:

   ```bash
   java -version; javac -version; mvn -version; echo "JAVA_HOME=$JAVA_HOME"
   ```

   All must report Java 21. If they do not, fix `JAVA_HOME` before continuing and record what
   you changed.

2. **Generate the project.**

   ```bash
   mvn -q archetype:generate -DgroupId=com.fsa.orderdesk -DartifactId=orderdesk \
     -DarchetypeArtifactId=maven-archetype-quickstart -DarchetypeVersion=1.4 \
     -DinteractiveMode=false
   ```

3. **Set the language level.** In `pom.xml`, set `maven.compiler.release` to 21 and the source
   encoding to UTF-8. Delete the generated JUnit 3 dependency and add `junit-jupiter` 5.10.2
   with `test` scope.

4. **Write something with a testable method.** Replace `App` with a class exposing a
   package-private pure method — a version string, or a small calculation — and a `main` that
   prints it.

5. **Write a test** under `src/test/java` in the same package, asserting on that method.

6. **Prove the lifecycle.** Run each and record what appears in `target/`:

   ```bash
   mvn clean;  mvn compile;  mvn test;  mvn package
   ```

   In `docs/lifecycle.md`, one line per command naming what it produced that the previous one
   did not.

7. **Make the jar runnable.** Configure `maven-jar-plugin` with a `mainClass`, then:

   ```bash
   mvn clean package && java -jar target/orderdesk-1.0-SNAPSHOT.jar
   ```

8. **Break it deliberately, once.** Add a `System.out.println` that references an undefined
   variable, run `mvn compile`, and paste the error into `docs/lifecycle.md` with one sentence
   explaining what the compiler is telling you. Then fix it.

9. **Add a `.gitignore`** excluding `target/`, and commit.

## Acceptance

- [ ] `docs/toolchain.txt` shows Java 21 from all four commands.
- [ ] `mvn clean package` succeeds from a fresh clone.
- [ ] `pom.xml` sets `maven.compiler.release` to 21 and UTF-8 encoding.
- [ ] JUnit is present with `test` scope and JUnit 3 is gone.
- [ ] At least one test exists and passes; `target/surefire-reports/` shows it ran.
- [ ] `java -jar target/*.jar` runs without a manifest error.
- [ ] `docs/lifecycle.md` distinguishes all four phases by their output.
- [ ] `target/` is not tracked by Git.

---

Next: [Java Syntax, Types & Methods](language-fundamentals.md).
