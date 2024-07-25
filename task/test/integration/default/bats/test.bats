#!/usr/bin/env bats

@test "Check if OpenResty is installed" {
  command -v openresty
  [ "$?" -eq 0 ]
}

@test "Check if Redis is installed" {
  command -v redis-server
  [ "$?" -eq 0 ]
}

@test "Check if Redis is running" {
  systemctl status redis-server | grep "active (running)"
  [ "$?" -eq 0 ]
}

@test "Fetch Redis test_key key" {
  curl -s http://localhost/test | grep "test_key"
  [ "$?" -eq 0 ]
}
