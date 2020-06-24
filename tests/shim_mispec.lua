return function(status, count, desc, err)
  if     status == "begin" then
    print(("\nTAP: 1..%d"):format(count))
  elseif status then
    print(("\nTAP: ok %d # %s\n"):format(count, desc))
  else
    print(("\nTAP: not ok %d # %s: %s\n"):format(count, desc, err))
  end
end
