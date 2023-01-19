#!/bin/bash -exu

apt update

apt install -y --no-install-recommends git \
               libtool clang \
               autoconf-archive pkg-config automake \
               make build-essential curl ca-certificates

rustup +nightly target add x86_64-unknown-none
rustup component add rust-src
rustup component add llvm-tools-preview
rustup override set nightly
cargo install xargo
cargo install bootimage

# avoid running prereq again
touch .prereq

# osteffen: install missing dependency
rustup component add rust-src

git submodule update --init --recursive --depth=1

# osteffen: Include path missing
cat << EOF | git apply --ignore-whitespace
From ed88b3cc2cc31544bf052bf52e78348bbf9b9175 Mon Sep 17 00:00:00 2001
From: Oliver Steffen <osteffen@redhat.com>
Date: Thu, 15 Dec 2022 16:36:42 +0100
Subject: [PATCH] build.rs: Set system include path

---
 build.rs | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/build.rs b/build.rs
index 0f0544e..56573c0 100644
--- a/build.rs
+++ b/build.rs
@@ -241,6 +241,9 @@ fn main() {
                 .to_str()
                 .unwrap()
         ))
+        .clang_arg(
+            "-I/usr/include/x86_64-linux-gnu/"
+        )
         .header("libtpm.h")
         .generate()
         .expect("Unable to generate bindings");
-- 
2.38.1
EOF

make
