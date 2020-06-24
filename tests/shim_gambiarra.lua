return function(e, test, msg, err)
  msg = msg or ""
  err = err or ""
  if     e == "pass" then
    print(("\nTAP: ok # %s: %s\n"):format(test, msg))
  elseif e == "fail" then
    print(("\nTAP: not ok # %s: %s: %s\n"):format(test, msg, err))
  elseif e == "except" then
    print(("\nTAP: not ok # %s: exn; %s: %s\n"):format(test, msg, err))
  else
    print(("\nTAP: # %s: %s: %s\n"):format(test, msg, err))
  end
end
