#! /usr/bin/env dash

# Takes multiple command line arguments presumed to be GLSL shaders, converts 
# it and produces a file of the same name with a '.hlsl' suffix.

# Error checking
if [ "$#" -eq "0" ]; then
    echo "Incorrect usage: ./glsl_converter.sh <glsl_file> <glsl_file> ..."
    exit 1
fi

# Loop through argument files
for file in "$@"; do
    if [ -f "$file" ]; then
        echo "Converting" "${file}..."

        # Using these rules: https://alastaira.wordpress.com/2015/08/07/unity-shadertoys-a-k-a-converting-glsl-shaders-to-cghlsl/
        # Todo: https://docs.microsoft.com/en-us/windows/uwp/gaming/glsl-to-hlsl-reference
        # Create new file 
        newFilename="${file}.hlsl"
        cat $file | sed 's/iTime/_Time.y/g' |
        sed -E 's/iResolution/_ScreenParams/g' |
        sed -E 's/vec([0-9])/float\1/g' |
        # sed 's/float([0-9])([0-9]+)/float\1(\2, \2, \2)/g' |
        sed -E 's/Texture2D/Tex2D/g' |
        sed -E 's/atan((.*), (.*))/atan2(\2, \1)/g' |
        sed -E 's/mix\(/lerp(/g' |
        # sed -E 's/ (.*) *= (.*)/mul(\1, \2)/g' |
        sed -E 's/Tex2D\((.*), (.*), (.*)\)/Tex2D(\1, \2)/g' |
        sed -E 's/mainImage(out vec4 fragColor, in vec2 fragCoord)/float4 mainImage(float2 fragCoord : SV_POSITION) : SV_Target/g' > "$newFilename"
    else
        echo "Can't find file:" "$file" 
    fi
done

# Success
echo ""
echo "Finished."
exit 0