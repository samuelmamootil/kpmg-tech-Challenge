function Get-ValueFromNestedObject ($object, $key) {
    $keys = $key -split '/'
    $value = $object
   # $value.Values 
   # $value.Values.Values
    foreach ($k in $keys) {
        $value = $value.$k 
    }
#####################################################################
#                            Optional                               #
        # Write-Output $value 

     # Ouput would be 
       <# Name                           Value
        ----                           -----
        b                              {c}
        c                              d -Final value
        d  
    #>
####################################################################

    # Write-Output $value --- Finally it will return the last value in the object 
    return $value
    
}
$object = @{“a”=@{“b”=@{“c”=”d”}}}
$key = 'a/b/c'
$value = Get-ValueFromNestedObject -object $object -key $key
#$object = @{“x”=@{“y”=@{“z”=”a”}}}
#$key = 'x/y/z'
#$value = Get-ValueFromNestedObject -object $object -key $key


