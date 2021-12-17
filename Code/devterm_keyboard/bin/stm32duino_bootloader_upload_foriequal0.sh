#!/bin/sh
# This script was generated using Makeself 2.4.3
# The license covering this archive and its contents, if any, is wholly independent of the Makeself license (GPL)

ORIG_UMASK=`umask`
if test "n" = n; then
    umask 077
fi

CRCsum="2558984783"
MD5="55a0c113bce9406de013f2f31020294b"
SHA="0000000000000000000000000000000000000000000000000000000000000000"
TMPROOT=${TMPDIR:=/tmp}
USER_PWD="$PWD"
export USER_PWD
ARCHIVE_DIR=`dirname "$0"`
export ARCHIVE_DIR

label="stm32duino_bootloader_upload"
script="./flash.sh"
scriptargs=""
cleanup_script=""
licensetxt=""
helpheader=''
targetdir="stm32duino_bootloader_upload"
filesizes="104864"
totalsize="104864"
keep="n"
nooverwrite="n"
quiet="n"
accept="n"
nodiskspace="n"
export_conf="n"
decrypt_cmd=""
skip="678"

print_cmd_arg=""
if type printf > /dev/null; then
    print_cmd="printf"
elif test -x /usr/ucb/echo; then
    print_cmd="/usr/ucb/echo"
else
    print_cmd="echo"
fi

if test -d /usr/xpg4/bin; then
    PATH=/usr/xpg4/bin:$PATH
    export PATH
fi

if test -d /usr/sfw/bin; then
    PATH=$PATH:/usr/sfw/bin
    export PATH
fi

unset CDPATH

MS_Printf()
{
    $print_cmd $print_cmd_arg "$1"
}

MS_PrintLicense()
{
  if test x"$licensetxt" != x; then
    if test x"$accept" = xy; then
      echo "$licensetxt"
    else
      echo "$licensetxt" | more
    fi
    if test x"$accept" != xy; then
      while true
      do
        MS_Printf "Please type y to accept, n otherwise: "
        read yn
        if test x"$yn" = xn; then
          keep=n
          eval $finish; exit 1
          break;
        elif test x"$yn" = xy; then
          break;
        fi
      done
    fi
  fi
}

MS_diskspace()
{
	(
	df -kP "$1" | tail -1 | awk '{ if ($4 ~ /%/) {print $3} else {print $4} }'
	)
}

MS_dd()
{
    blocks=`expr $3 / 1024`
    bytes=`expr $3 % 1024`
    # Test for ibs, obs and conv feature
    if dd if=/dev/zero of=/dev/null count=1 ibs=512 obs=512 conv=sync 2> /dev/null; then
        dd if="$1" ibs=$2 skip=1 obs=1024 conv=sync 2> /dev/null | \
        { test $blocks -gt 0 && dd ibs=1024 obs=1024 count=$blocks ; \
          test $bytes  -gt 0 && dd ibs=1 obs=1024 count=$bytes ; } 2> /dev/null
    else
        dd if="$1" bs=$2 skip=1 2> /dev/null
    fi
}

MS_dd_Progress()
{
    if test x"$noprogress" = xy; then
        MS_dd "$@"
        return $?
    fi
    file="$1"
    offset=$2
    length=$3
    pos=0
    bsize=4194304
    while test $bsize -gt $length; do
        bsize=`expr $bsize / 4`
    done
    blocks=`expr $length / $bsize`
    bytes=`expr $length % $bsize`
    (
        dd ibs=$offset skip=1 count=0 2>/dev/null
        pos=`expr $pos \+ $bsize`
        MS_Printf "     0%% " 1>&2
        if test $blocks -gt 0; then
            while test $pos -le $length; do
                dd bs=$bsize count=1 2>/dev/null
                pcent=`expr $length / 100`
                pcent=`expr $pos / $pcent`
                if test $pcent -lt 100; then
                    MS_Printf "\b\b\b\b\b\b\b" 1>&2
                    if test $pcent -lt 10; then
                        MS_Printf "    $pcent%% " 1>&2
                    else
                        MS_Printf "   $pcent%% " 1>&2
                    fi
                fi
                pos=`expr $pos \+ $bsize`
            done
        fi
        if test $bytes -gt 0; then
            dd bs=$bytes count=1 2>/dev/null
        fi
        MS_Printf "\b\b\b\b\b\b\b" 1>&2
        MS_Printf " 100%%  " 1>&2
    ) < "$file"
}

MS_Help()
{
    cat << EOH >&2
${helpheader}Makeself version 2.4.3
 1) Getting help or info about $0 :
  $0 --help   Print this message
  $0 --info   Print embedded info : title, default target directory, embedded script ...
  $0 --lsm    Print embedded lsm entry (or no LSM)
  $0 --list   Print the list of files in the archive
  $0 --check  Checks integrity of the archive

 2) Running $0 :
  $0 [options] [--] [additional arguments to embedded script]
  with following options (in that order)
  --confirm             Ask before running embedded script
  --quiet               Do not print anything except error messages
  --accept              Accept the license
  --noexec              Do not run embedded script (implies --noexec-cleanup)
  --noexec-cleanup      Do not run embedded cleanup script
  --keep                Do not erase target directory after running
                        the embedded script
  --noprogress          Do not show the progress during the decompression
  --nox11               Do not spawn an xterm
  --nochown             Do not give the target folder to the current user
  --chown               Give the target folder to the current user recursively
  --nodiskspace         Do not check for available disk space
  --target dir          Extract directly to a target directory (absolute or relative)
                        This directory may undergo recursive chown (see --nochown).
  --tar arg1 [arg2 ...] Access the contents of the archive through the tar command
  --ssl-pass-src src    Use the given src as the source of password to decrypt the data
                        using OpenSSL. See "PASS PHRASE ARGUMENTS" in man openssl.
                        Default is to prompt the user to enter decryption password
                        on the current terminal.
  --cleanup-args args   Arguments to the cleanup script. Wrap in quotes to provide
                        multiple arguments.
  --                    Following arguments will be passed to the embedded script
EOH
}

MS_Check()
{
    OLD_PATH="$PATH"
    PATH=${GUESS_MD5_PATH:-"$OLD_PATH:/bin:/usr/bin:/sbin:/usr/local/ssl/bin:/usr/local/bin:/opt/openssl/bin"}
	MD5_ARG=""
    MD5_PATH=`exec <&- 2>&-; which md5sum || command -v md5sum || type md5sum`
    test -x "$MD5_PATH" || MD5_PATH=`exec <&- 2>&-; which md5 || command -v md5 || type md5`
    test -x "$MD5_PATH" || MD5_PATH=`exec <&- 2>&-; which digest || command -v digest || type digest`
    PATH="$OLD_PATH"

    SHA_PATH=`exec <&- 2>&-; which shasum || command -v shasum || type shasum`
    test -x "$SHA_PATH" || SHA_PATH=`exec <&- 2>&-; which sha256sum || command -v sha256sum || type sha256sum`

    if test x"$quiet" = xn; then
		MS_Printf "Verifying archive integrity..."
    fi
    offset=`head -n "$skip" "$1" | wc -c | tr -d " "`
    fsize=`cat "$1" | wc -c | tr -d " "`
    if test $totalsize -ne `expr $fsize - $offset`; then
        echo " Unexpected archive size." >&2
        exit 2
    fi
    verb=$2
    i=1
    for s in $filesizes
    do
		crc=`echo $CRCsum | cut -d" " -f$i`
		if test -x "$SHA_PATH"; then
			if test x"`basename $SHA_PATH`" = xshasum; then
				SHA_ARG="-a 256"
			fi
			sha=`echo $SHA | cut -d" " -f$i`
			if test x"$sha" = x0000000000000000000000000000000000000000000000000000000000000000; then
				test x"$verb" = xy && echo " $1 does not contain an embedded SHA256 checksum." >&2
			else
				shasum=`MS_dd_Progress "$1" $offset $s | eval "$SHA_PATH $SHA_ARG" | cut -b-64`;
				if test x"$shasum" != x"$sha"; then
					echo "Error in SHA256 checksums: $shasum is different from $sha" >&2
					exit 2
				elif test x"$quiet" = xn; then
					MS_Printf " SHA256 checksums are OK." >&2
				fi
				crc="0000000000";
			fi
		fi
		if test -x "$MD5_PATH"; then
			if test x"`basename $MD5_PATH`" = xdigest; then
				MD5_ARG="-a md5"
			fi
			md5=`echo $MD5 | cut -d" " -f$i`
			if test x"$md5" = x00000000000000000000000000000000; then
				test x"$verb" = xy && echo " $1 does not contain an embedded MD5 checksum." >&2
			else
				md5sum=`MS_dd_Progress "$1" $offset $s | eval "$MD5_PATH $MD5_ARG" | cut -b-32`;
				if test x"$md5sum" != x"$md5"; then
					echo "Error in MD5 checksums: $md5sum is different from $md5" >&2
					exit 2
				elif test x"$quiet" = xn; then
					MS_Printf " MD5 checksums are OK." >&2
				fi
				crc="0000000000"; verb=n
			fi
		fi
		if test x"$crc" = x0000000000; then
			test x"$verb" = xy && echo " $1 does not contain a CRC checksum." >&2
		else
			sum1=`MS_dd_Progress "$1" $offset $s | CMD_ENV=xpg4 cksum | awk '{print $1}'`
			if test x"$sum1" != x"$crc"; then
				echo "Error in checksums: $sum1 is different from $crc" >&2
				exit 2
			elif test x"$quiet" = xn; then
				MS_Printf " CRC checksums are OK." >&2
			fi
		fi
		i=`expr $i + 1`
		offset=`expr $offset + $s`
    done
    if test x"$quiet" = xn; then
		echo " All good."
    fi
}

MS_Decompress()
{
    if test x"$decrypt_cmd" != x""; then
        { eval "$decrypt_cmd" || echo " ... Decryption failed." >&2; } | eval "gzip -cd"
    else
        eval "gzip -cd"
    fi
    
    if test $? -ne 0; then
        echo " ... Decompression failed." >&2
    fi
}

UnTAR()
{
    if test x"$quiet" = xn; then
		tar $1vf -  2>&1 || { echo " ... Extraction failed." > /dev/tty; kill -15 $$; }
    else
		tar $1f -  2>&1 || { echo Extraction failed. > /dev/tty; kill -15 $$; }
    fi
}

MS_exec_cleanup() {
    if test x"$cleanup" = xy && test x"$cleanup_script" != x""; then
        cleanup=n
        cd "$tmpdir"
        eval "\"$cleanup_script\" $scriptargs $cleanupargs"
    fi
}

MS_cleanup()
{
    echo 'Signal caught, cleaning up' >&2
    MS_exec_cleanup
    cd "$TMPROOT"
    rm -rf "$tmpdir"
    eval $finish; exit 15
}

finish=true
xterm_loop=
noprogress=n
nox11=n
copy=none
ownership=n
verbose=n
cleanup=y
cleanupargs=

initargs="$@"

while true
do
    case "$1" in
    -h | --help)
	MS_Help
	exit 0
	;;
    -q | --quiet)
	quiet=y
	noprogress=y
	shift
	;;
	--accept)
	accept=y
	shift
	;;
    --info)
	echo Identification: "$label"
	echo Target directory: "$targetdir"
	echo Uncompressed size: 312 KB
	echo Compression: gzip
	if test x"n" != x""; then
	    echo Encryption: n
	fi
	echo Date of packaging: Fri Dec 17 11:47:32 CST 2021
	echo Built with Makeself version 2.4.3
	echo Build command was: "/usr/local/bin/makeself.sh \\
    \"stm32duino_bootloader_upload\" \\
    \"stm32duino_bootloader_upload_foriequal0.sh\" \\
    \"stm32duino_bootloader_upload\" \\
    \"./flash.sh\""
	if test x"$script" != x; then
	    echo Script run after extraction:
	    echo "    " $script $scriptargs
	fi
	if test x"" = xcopy; then
		echo "Archive will copy itself to a temporary location"
	fi
	if test x"n" = xy; then
		echo "Root permissions required for extraction"
	fi
	if test x"n" = xy; then
	    echo "directory $targetdir is permanent"
	else
	    echo "$targetdir will be removed after extraction"
	fi
	exit 0
	;;
    --dumpconf)
	echo LABEL=\"$label\"
	echo SCRIPT=\"$script\"
	echo SCRIPTARGS=\"$scriptargs\"
    echo CLEANUPSCRIPT=\"$cleanup_script\"
	echo archdirname=\"stm32duino_bootloader_upload\"
	echo KEEP=n
	echo NOOVERWRITE=n
	echo COMPRESS=gzip
	echo filesizes=\"$filesizes\"
    echo totalsize=\"$totalsize\"
	echo CRCsum=\"$CRCsum\"
	echo MD5sum=\"$MD5sum\"
	echo SHAsum=\"$SHAsum\"
	echo SKIP=\"$skip\"
	exit 0
	;;
    --lsm)
cat << EOLSM
No LSM.
EOLSM
	exit 0
	;;
    --list)
	echo Target directory: $targetdir
	offset=`head -n "$skip" "$0" | wc -c | tr -d " "`
	for s in $filesizes
	do
	    MS_dd "$0" $offset $s | MS_Decompress | UnTAR t
	    offset=`expr $offset + $s`
	done
	exit 0
	;;
	--tar)
	offset=`head -n "$skip" "$0" | wc -c | tr -d " "`
	arg1="$2"
    if ! shift 2; then MS_Help; exit 1; fi
	for s in $filesizes
	do
	    MS_dd "$0" $offset $s | MS_Decompress | tar "$arg1" - "$@"
	    offset=`expr $offset + $s`
	done
	exit 0
	;;
    --check)
	MS_Check "$0" y
	exit 0
	;;
    --confirm)
	verbose=y
	shift
	;;
	--noexec)
	script=""
    cleanup_script=""
	shift
	;;
    --noexec-cleanup)
    cleanup_script=""
    shift
    ;;
    --keep)
	keep=y
	shift
	;;
    --target)
	keep=y
	targetdir="${2:-.}"
    if ! shift 2; then MS_Help; exit 1; fi
	;;
    --noprogress)
	noprogress=y
	shift
	;;
    --nox11)
	nox11=y
	shift
	;;
    --nochown)
	ownership=n
	shift
	;;
    --chown)
        ownership=y
        shift
        ;;
    --nodiskspace)
	nodiskspace=y
	shift
	;;
    --xwin)
	if test "n" = n; then
		finish="echo Press Return to close this window...; read junk"
	fi
	xterm_loop=1
	shift
	;;
    --phase2)
	copy=phase2
	shift
	;;
	--ssl-pass-src)
	if test x"n" != x"openssl"; then
	    echo "Invalid option --ssl-pass-src: $0 was not encrypted with OpenSSL!" >&2
	    exit 1
	fi
	decrypt_cmd="$decrypt_cmd -pass $2"
	if ! shift 2; then MS_Help; exit 1; fi
	;;
    --cleanup-args)
    cleanupargs="$2"
    if ! shift 2; then MS_help; exit 1; fi
    ;;
    --)
	shift
	break ;;
    -*)
	echo Unrecognized flag : "$1" >&2
	MS_Help
	exit 1
	;;
    *)
	break ;;
    esac
done

if test x"$quiet" = xy -a x"$verbose" = xy; then
	echo Cannot be verbose and quiet at the same time. >&2
	exit 1
fi

if test x"n" = xy -a `id -u` -ne 0; then
	echo "Administrative privileges required for this archive (use su or sudo)" >&2
	exit 1	
fi

if test x"$copy" \!= xphase2; then
    MS_PrintLicense
fi

case "$copy" in
copy)
    tmpdir="$TMPROOT"/makeself.$RANDOM.`date +"%y%m%d%H%M%S"`.$$
    mkdir "$tmpdir" || {
	echo "Could not create temporary directory $tmpdir" >&2
	exit 1
    }
    SCRIPT_COPY="$tmpdir/makeself"
    echo "Copying to a temporary location..." >&2
    cp "$0" "$SCRIPT_COPY"
    chmod +x "$SCRIPT_COPY"
    cd "$TMPROOT"
    exec "$SCRIPT_COPY" --phase2 -- $initargs
    ;;
phase2)
    finish="$finish ; rm -rf `dirname $0`"
    ;;
esac

if test x"$nox11" = xn; then
    if tty -s; then                 # Do we have a terminal?
	:
    else
        if test x"$DISPLAY" != x -a x"$xterm_loop" = x; then  # No, but do we have X?
            if xset q > /dev/null 2>&1; then # Check for valid DISPLAY variable
                GUESS_XTERMS="xterm gnome-terminal rxvt dtterm eterm Eterm xfce4-terminal lxterminal kvt konsole aterm terminology"
                for a in $GUESS_XTERMS; do
                    if type $a >/dev/null 2>&1; then
                        XTERM=$a
                        break
                    fi
                done
                chmod a+x $0 || echo Please add execution rights on $0
                if test `echo "$0" | cut -c1` = "/"; then # Spawn a terminal!
                    exec $XTERM -e "$0 --xwin $initargs"
                else
                    exec $XTERM -e "./$0 --xwin $initargs"
                fi
            fi
        fi
    fi
fi

if test x"$targetdir" = x.; then
    tmpdir="."
else
    if test x"$keep" = xy; then
	if test x"$nooverwrite" = xy && test -d "$targetdir"; then
            echo "Target directory $targetdir already exists, aborting." >&2
            exit 1
	fi
	if test x"$quiet" = xn; then
	    echo "Creating directory $targetdir" >&2
	fi
	tmpdir="$targetdir"
	dashp="-p"
    else
	tmpdir="$TMPROOT/selfgz$$$RANDOM"
	dashp=""
    fi
    mkdir $dashp "$tmpdir" || {
	echo 'Cannot create target directory' $tmpdir >&2
	echo 'You should try option --target dir' >&2
	eval $finish
	exit 1
    }
fi

location="`pwd`"
if test x"$SETUP_NOCHECK" != x1; then
    MS_Check "$0"
fi
offset=`head -n "$skip" "$0" | wc -c | tr -d " "`

if test x"$verbose" = xy; then
	MS_Printf "About to extract 312 KB in $tmpdir ... Proceed ? [Y/n] "
	read yn
	if test x"$yn" = xn; then
		eval $finish; exit 1
	fi
fi

if test x"$quiet" = xn; then
    # Decrypting with openssl will ask for password,
    # the prompt needs to start on new line
	if test x"n" = x"openssl"; then
	    echo "Decrypting and uncompressing $label..."
	else
        MS_Printf "Uncompressing $label"
	fi
fi
res=3
if test x"$keep" = xn; then
    trap MS_cleanup 1 2 3 15
fi

if test x"$nodiskspace" = xn; then
    leftspace=`MS_diskspace "$tmpdir"`
    if test -n "$leftspace"; then
        if test "$leftspace" -lt 312; then
            echo
            echo "Not enough space left in "`dirname $tmpdir`" ($leftspace KB) to decompress $0 (312 KB)" >&2
            echo "Use --nodiskspace option to skip this check and proceed anyway" >&2
            if test x"$keep" = xn; then
                echo "Consider setting TMPDIR to a directory with more free space."
            fi
            eval $finish; exit 1
        fi
    fi
fi

for s in $filesizes
do
    if MS_dd_Progress "$0" $offset $s | MS_Decompress | ( cd "$tmpdir"; umask $ORIG_UMASK ; UnTAR xp ) 1>/dev/null; then
		if test x"$ownership" = xy; then
			(cd "$tmpdir"; chown -R `id -u` .;  chgrp -R `id -g` .)
		fi
    else
		echo >&2
		echo "Unable to decompress $0" >&2
		eval $finish; exit 1
    fi
    offset=`expr $offset + $s`
done
if test x"$quiet" = xn; then
	echo
fi

cd "$tmpdir"
res=0
if test x"$script" != x; then
    if test x"$export_conf" = x"y"; then
        MS_BUNDLE="$0"
        MS_LABEL="$label"
        MS_SCRIPT="$script"
        MS_SCRIPTARGS="$scriptargs"
        MS_ARCHDIRNAME="$archdirname"
        MS_KEEP="$KEEP"
        MS_NOOVERWRITE="$NOOVERWRITE"
        MS_COMPRESS="$COMPRESS"
        MS_CLEANUP="$cleanup"
        export MS_BUNDLE MS_LABEL MS_SCRIPT MS_SCRIPTARGS
        export MS_ARCHDIRNAME MS_KEEP MS_NOOVERWRITE MS_COMPRESS
    fi

    if test x"$verbose" = x"y"; then
		MS_Printf "OK to execute: $script $scriptargs $* ? [Y/n] "
		read yn
		if test x"$yn" = x -o x"$yn" = xy -o x"$yn" = xY; then
			eval "\"$script\" $scriptargs \"\$@\""; res=$?;
		fi
    else
		eval "\"$script\" $scriptargs \"\$@\""; res=$?
    fi
    if test "$res" -ne 0; then
		test x"$verbose" = xy && echo "The program '$script' returned an error code ($res)" >&2
    fi
fi

MS_exec_cleanup

if test x"$keep" = xn; then
    cd "$TMPROOT"
    rm -rf "$tmpdir"
fi
eval $finish; exit $res
� T�a�]}w�F��_�SlEn��Ȗd[~		�Z�\
^n�9�ZZ�*�d�R��g�3�+�q�����li_fggv~3;���a�՟��D*k]������ǿ���������=����|l�x�&���m���p�v�ٴ�n܀��s���q�\f<Rn�;?
���'��y+�� ������R�Ҷ^#��Dm���;β�7���_��E����o1��F�dh�YuA8�,Kր�b�R�T�k���$y+W� >�D�	�e��&�x�/o��N����z���޶���]ϳ=Oe��g�-u�����h�j����o��-��Y��^����>��rd�4n��1�i�JSvm�?�[2�୏����BJ.t�ߊ�����\�� MƌC�x�QQ�F==��<
�Wh�(�F,Nb�O�&�%�%�L�,�2�!4��H�Ir����x�I$Wf�d����Jl"��#�=PT������hb�P���P�[��aP��)��5è1P/K�,)�|b�>�ݶ��o��Ck�S)�eaI�<bJUYlh�42!3f�g�ڬ	���#0N�'�}p~2�~6���qN�_�P��������p�����߳�`��N���ߛ��m?��w�S��^��������l,*�����h�T!S��$���|,�l�� ә�;Oh 񌍸\a����x�81�/@+�×�s�C�p����	��:����!}�,�"����6GaLm`��y��ࠩ�F> �󀅁��|(b��h��s��$�B�5'�*ꎓT0�f� ̡a>{���
���������?=ػw��s��I(oŬ*���k�v�7j���'��c�N}R݀�@��If�^��M@5��>~d��Գ�zl��
i�s	ɂ|�>N�inI`1�(�d���X}�DPUwlT�L�Ƒ��;f�ň��_�d�W���T7��F�H���e����
ɯc����
5�&�B��
�!�@`6`s�	D&`�����p] �$!�G@%�"K�&\����fY���XM��AMp�+b��ǉ~ RY0�x8�'��ɀ%y6���/����"v8��2�}�i6EL����� _�B�����3X�"(��1LD��%l�
A�H�l<S��cC��G/����E:����Ϡ�����0Q�6[!�²q�~zO���f�&[��n �����_��gw�N��iIQ(��2 �&��6� ,��1<����B���y?K���ߡ�c�1�(6E�V����̥"�Ә&��x(����
�Qg�,[y�Y��2���@'�� �|�|2�3�X2���M�W���8��c�$��9����U�V�bН�|]��,� l)>�~̶�bձ��*B��?�q�Xw�"��0n��ޯ"�=
�7�N�����_߯�G��wy|�j+*��^�WMj����^ӌ��?:(&K0el�9tdT��$0gל��[��;x���&���m�ꬒ���8���ɲ)��Z� �!��p����~8�Q��bZ�^X��IS�\�#Q�pIz
+�����@2LrV,
J��;P=���e�~�:����Ԝ[�?�'��C[)z�2ۀ������g�9"u����R9������ J)y􃡍T�"����x�t,�%|�81�z`T�\���E�4�X��������r�GӚ�^��mv��Y����Ry��$s\��O@�*MzOqb�i
z쥉�`�_���F�+p���Zbt�Е�"R<�R��N�X�(	�%>��Z}��.�o���D��n=
 +�z�s�F-ǸĜ �|խ�)�y��7o��1H�\�_���-=Q�$>��=���(V��<{�����g8y���d/hZA�+Ǥ�Ɋ�O��Q���}\Б��Y)k����g����Z���pe����֟f���%����Iz|�7�z\ϵ�L��2��)�݂e�^�z��bTWZ~DP�uV�ڳ���?}�̻A�\��dʣ�YL�����L�5��ٲ������͢��zQ�b$&���63xK���(D�e��a���XP��OR�\��j�Kb�K�(u�	��E�-��� �8��
h �����"5�Ep��D-.��f�@ �%E�ѽZ+��G�'�����j�pJ�U*aLL�-5�M��]��a��H����5��6M�Rvʨ�cz�a���z� u�] �5q" �Sr6HF�����kuIѫ���5A�s|��
��d{�p���Çۻ8h+`՗���վ]eّ�,����b���۷��?�Ÿ�;�=v���Z��y��BC�'��tl�-�9r�{,�}XT�"W;	��I��:��*'xN��9�	���r�@0�-C� Z/��4-�����
�n�B��f+�@PoG���D����"5@�)�i����S�yL�fT�������M�e�X�:�隴�����6�2����
7ĉj��'�i����3
�*����*X�X�A��ښ�,�=Z��D��F��W��#lW�#�$��⚋U_<}��eU��(�2\��⬸�U�;�#L3d5�x��H
�X��Ba,
f<x�g�0��c�؍bc���Tv��r���	Wo
)�W�yQB�#��#����^�/���~�ia��wҩ�-�Gsj����d��Z<���@8E�6]+��|qM���io۟�1`!�;1��M��院��+<5��N'a�xVo&Y���+�������:��krOzFEm%��.�/�h�8b�:�M�p�;��*b!��n/���WT7��ʾ��o�!PYjOe�hpN\�v�u�Jb��00F�a�t�B�W�)v]�t�'�
��n��x]ue�)e�����]�b�B��yw(k��ۤS]Z�L���D3�!-5��㻱���*�\����p����o�w ��^���]��������i6O��Q������d���Q���
��#�D����T�Az��O�oC
B��l0��� ������*]q��i�7K&�ϊ��Qeй��'��L!J�~���}V-(#.E�-^�P��`	ynG��9���� 6������C?��^
A�d���;)(P
uQ�j�$��
��1�a 6�,��|�Kw��@er$EQ��-\N����}r�b.\��;0� ���e���a��L�U�V�f$��Ʌ�'<<і�EdN������-`j�ͣ�q�̪�F�g�'�V�Pa6��2�*6�u)�����Z���P��P B&���S�Q6�'-w�ŀ�/X��YbΌ���Y��U���L���Bu����ϊ�s�[�C�~��r�i�����6'Ru��\�S3WH�v�VM]���d%9��ŤW.4a���=2t��M��s��s����n��~�"5$��V����-�|,��[E	�{�XE1��0Q�Ū�ӗ��Y��@:^�5�u�M���K��rk��
n��:��{_��n�)���{�=��s�=��s�!��ȩ�_L�����'[�Ր�IU�_��AT��6%�Y �=�d��� ��v�H����M�Z����)	q3�J�?�%m��QFK
���S&]r�86���(b	�sB��:�
,|"�?��(�P{�ѝ
%�'ِ���P�	6��.���� ޒwԍ�;�.Ig)G��(S4�� $.t���!
)4u*���!�h���#⬪�:Hg@�	��8f8���D���$ӷ]
҄��u!���
u�
���T�t���V����P����b�?�i�ÉOzvhgD7T8�����0)5R �O�I�4��Jh��$�����_��q�,j�e)�����
�QOxٙ����T��h��^-�br�[f)^�iQ
5���_�
��
�ȝ�����9�C���y�?F��po���^0��|u�.�iR�� �"|�_d��ĎTU�P�8ʂ�@r��g�7�Y��
�$q2A�)̘2	,JɃ=�хU
���i��>��ʠW��Kj��ǗWTX�l���7Q�?8���_4q\��ӌ��N�5U���`g���Ĥ�cnR�%�<k���g�e0�f)�Yp��N���lt���r�0��VH��/�|����`C�Pw.-��KY0%u�	qJ	�5�,H���y� ��e��<��0h���A���CK:N��ťh�4�"D��T�!��n������ra��Na"Bd"�%�S��*h�`�%*N0 -��Mܳ5`�7K2����f3'��������������5���K?4�����_����^V�����<���
S@2��o����
4�_� z�ǔ{��q��a�t�|�$c�XZ(M�u��0xT����,��Iz�4MNd�>��3�Q�L�T�8>��J���[+�&����U�����/���ʙ�'������YMg,u���q�����H{���Ŭ�d �����klD
��X�aD��t	N�a��$p��y��a�LN'����#d�z�v��rɀV�!� X���0Z�FZہIw�R�����ѣ4����y�N.ɾI�K!�(t�Ns���n��eIwq�6��bmF�b;/��^̒��X���D��E��W�$P\+�ee��0�����U�>����<���񬓷ۜ6�(�,��C�Jv�¸�Еu����,X��z0i� �����9�H�q��d�!}e��V�&�͂�`��:0��%�������}y%.���iu95��Î�$���;9����.3g���h3�͢�!A��z�
*�!&�\�4�U�H��e6[�6'���au8�N��w�\� I�h��&�)TX����G�1�w�W(�� �����O���������X��<h��� �v��"������S�������vjܦ���q�:nS���w����>w���,�F���F�I0A�7?�oi�_���%l��lfc�������������߂�7�F�!����l���
��
C��T%
���1孥�jV[l�Up�tjy���"�7����T�40)V��e��x�^n��4_
��N=;�R�_��t�Pv۫�m�3�go�[7z�U���Ƀ#�����G�J�Lx�ʶq-Z����x�(e9�5+p�zB7�2���n\vb��	�����������ǋ;�6�ˋaT�-F}����}5*c��%�v��s��3�|��,����b���t�&�������/�4�Qu�y���r6�r�)�yd����grpq��4��w��Pj�W)X�
/��O<�t� ���QBۺ<�8(k��;�Z��H_n�	[���dڵd��Z������(�%S`�sE������1����������!�}­J"MoN&Te�m�*z���k6j�d��U:xf�D�x�wzS��L�8��,���� �A��F��-Q�=��^��l|N��8_�����׋�f̉;d��t�H�	����FshI&<�T?�4�+`��g��A
�T����1����5�]:��K�ǚ������L���K�i��Nim5�a�Ţ"����G����:j�#f�de��{�{�;70�\x�1s���uD����B��g������0"�Fph `���?��8 
WŃߕY�hygp��)T�r@��X:��/��t
������?�5
{/�x�t^���N�!�Bq���@n��_��pț�M��+H��j�|�C�����txe�.�~�\m���W���ƉW��c�������͚����������Z�?���28<� �O���̘����(���������"�l��_��ފ��(�3#|gx�V��lS��I
 	�(h4��&�BC��[�
�b��RYu
�����v����k�ɣBq4��'	|�%XP#��|=b��ٴ��zȭKf�"_��@�k���v'�jK5	�R9���4��*߹Đ��M�UnbU���k�r;(��9�X��8U&V��Ʊ���гC>�_H�طϽ��5�f��5d����uq����#7ާv���*���j�u;�mt,m-=M-���_�bS�I��˹~�-��O����9��ƻ��)��Ϗ��|?���Qy6��Q�p���O�k���D�Y4��$��;if�a	D�($����a�0����� X,�y���������`<����@,�C��g�?鿿O��<�������������Ϥ�_���)��Pn�SaD	8O�7W9-���bĨ��j#5��UNNb����;n���b���C�&�m&y������POLguȴ�9��yѣ����Y�g�����^SZ�Dč]#^E
�� �[O>B�Z�"x�U���̦�t�X�1��½�}7~:�RyLi�9���2��:���g�q�
�H,H�	x�� P@*� �ο������L������-t���E����J������A�����2��1��/�߮�3���C�2�G�� �G�I�E~��eζ�Dv�_��F�H�\����T�z�&�ͱq��~�+-".C��3�Z�o�ŵe����������c��=�$v���Ȣe�d%о��~�P߃��yC���u��k�YO�H�h�aj˚���+ճ.�����i�N�F�E[����ɂO�a��{Jp��7�l�|'�B(�w�j�%A2�[/q�D�t֬�Մ�b�x��I=Æ���dOoW���	�;7�c�6O7�\O5j�vSr*8��m��L��~�\�1�9���IT2 A�AcaƐ��P
�!���?����0��������i<������  Ƣ�����,C[L��K���? �g��_��{J��u��f���̅(��򏝫�a��H�@
B�R@O��s>�H��$"v>�����3�?C�>���������ϙ�C3�?�b�O��=�`�������#���?4���������R���_i_T`���5/��>:��}W��M���"�-i{�X��wn�'D��żs��&�����@�]��κan�i����oz;�&���!HX�R��L=Q:�(��K�b�j�5/˪i�kihKS���G��b\�CC�7l�v��q��%���'ߋ���*$!x,�`!*�D�S@4�BF�ԙ�t`ITL��� �����C�H�����Oz����{��L�

c�����{ӗ�Z� ����ـn�0T��ܴG덑�xi-��[gy�u�N�4�,3-�k��a&�j*�����S���8/ܬ�.�¯�:��#�KID�o��o��{��TU��66P�7��o��|��Y��d��*��8kE/�pa��Y�%����i\`W±�?>�$��#���'�	�3�ZU�Du�iw?��u�:��=�"<X��)�GfϽ؃�J�Ѽ�����#6��M�'9��[{#9XG؝,�h��,G��;izx�e;\��Թ(V׳�ZT�|�4��f������~,)����4�����kS�#o��r�Q�:���O'5y��x�������r�Kb�$-��<��~hAB5:���o�rB�%��]����,;2���R��t��X�.�ԏ��
O�f�� ��W��I^b�D�iQ,OŝRN�k%쯮M��t���a�H��ok�CP��작��g՝��z��m�+��g��n��+�ֳ�=6���<֑F����^��ep�Og��~�A�O��Es}�SJ��W���m9l�eI�t��f~f�U�����R���KQ�K��=	���]��I�egz�� �����tc�~���T[�=l��*��)��ڕ��\�
m���w�m�L_���RD��-�Bk��΍�Zn��C�<��ou�5?��J� ;g�A	6`X��f�����J��壦9��a+�~hd���K���e�_[sNm��-.�q�2���<.������q�a7,���u-�gi�wIl��+�qA�e�|�����b-+�y�����;�p��w�g��(EQ֐D��Kc��[��YH(ƾ�РDBE�DT���"4�l1�P�a��]�<�s���\���\���3���\��|_����|��~��gXj��Ku����i�r���v*ʵp֒f�0��d&B��myVY���".�	q�;a8������&�<�%i����,�T>�qqC)<D1�n|Y2�-I�,*�J�x�Rce��0�6�͵4��i��L���g*�w6�6�(=��I-i�Dy?IV���:et8'�Co��"���y�R��s�i��8���>)_�ܭw<�JQ��,�V#DD8�,=�>��x}��@�}�����
�ԝ>���O�ͩS��X�׃���������y�v�>���c.w�$�7%��di"-�����k��E"_���� �H,��� (���6@ȟq��_�f������Ë�����v�/t�����������2k��'�?J�����C�/����g���8� ƵC�:��O�6�����Ʌ]�
����}œ0��n}��"���!M�,Y� |P7�s{�r�^ys&[�:�{Jh���S=��w�Q�+}�:�����+]_RW=�Nns�(�����n���S��y<�A&��俔�o���m	x ���pX���`0���Bq ����9�?���g���K���������P3����Gi�~�"����0��'������l��� `g�6��բ�j���R4[OcMFQ��Z����f������ [
��Nb�������(AnZ[�$�"l@ �� �[ �f�[�G���_G����^ߟ��i�7/0����k������o^X��a���\��m~��o�����m�v�Mg�C�L����'�g���nWzw���C�̸OG�AB��n"�ܪ+$�9JMT�a\w��.�'��u��
x�#��U��.��4̯�gݲjg}���w��~���! �	"�PX(Ė G��8�"@PܦK�l���\�e��_��o ȯ��p(���I��������>���������,�RW�����X���Or,�}"�w��<�����P��/���q� no�g��Y��̖-i|9L�����@����0�-ܖ� Bxk�Á�
i+{wN��U��u̎J���,�e�ԈȊ�͊�y����iP %�A��CI��>��M
Q��u6�6H5�����ɞ��U��u:�tk�	�ԸU�	6*)�t6X���ǉ1bß"��O�t�ᔱs@�u�� ��{���K|�'��\��{]�>�q}��y�)�:�<��&B��u��/sz�R��Z�~[G���P��	����u�
\�:��`�u����듚�4{;��H����EcF<tK�
`��(ؗ:$��-\���]�p#�:zwN^8+B.����?��P|���H�c���1�F)H��Z�"P�@�����%��������%5ϼ<�h�#g���&�b�G-�%ǚm��ɱU�9T�iײVmϤ�棨���8X�R�x1/�����%�+�I|�u�vV_>M�>~(ڞ�����s,^Tez�AW���G%�є�!��H�.bgϴ�~�%���rJ���c���u=S)Y�kM��9z��z����!�G8��wn헖~tiV #��y�,���=��	�����;6���k���>ߎ���F�ן�,���S84�`V2��1�gV�o^�Z%���Tl�_���`�J�y�K'����7�a�<r0���LSnp�D�����	R����_d����5j>�`�;V��\�ۉ��V�s�I���={�QU��t�h�U�j�n���N`��a��{���^���UǱ�
��[�f*Mũ���r��;k;� R�,�v:����UL��S�I�Uq��'a��
�׳cn����o�J�l�j4{8�^�pl���h�}p��ƛ�7'��v���/_6�mYЫ��̚���:�}}�@�Di�F9F~���v��2����K�R�E�~����%�+V��̳lF��b���r e-_:�"s�e�A�ڐ������\J~�^���jź���j`��@��1�Oo��4>����	�+^��wX/֜S���>�*�r�Z!P� :���T8P*�5ݶ񸚾Y��W/�e���j�7Z�8JG3�{T���Q�Гvsվ���d�f����qKƂ��9�~� ���b��pF<0�j|φ_[i���2����[�|Q�S�^Hy�:�:4�X	��}ը��{z�čL�Q�5��u|�V���w��8�6A]�_4GuLA\���fK�up�&�6j�:�>�*�� �ݱxsҧ7]�e#�`ߘ����Gn&��G����(�h�-�O*�r�������gTҞJ��1��Kv`��``�<��

 �WD�+ lm �7(�^l� ���P0f��@�O�����Q8��������7�0z8�{�����/������������R��߷_4�����78^��u)�J����E,if��֕���ؿ�8�JUz�Y�`dtY>'>1��Lu�b�PT��'��?��
�W�/*���ٍ�o�w7��T~�br��#~D�Q�֬�D��X�I�oXk��Գ�$ú�.�B%0	ϔy��SΜ����!��k�A���'˒"9fU �Ǹ�b�C䋚��l}	v�wۤ/���!G��Zv�Y�e.j
�0mؑm�����lӷ8r�p
��s�n��|� Í{��R*����&UnA�`i�(�&?��O��g�Q3lV�?g3�m�3l1qT���
�"���(XRk����]�Â��F��%^ݦz�0�d2���X���D�N��]B˙���]�C��~�I�6$�s���/�jV��Zה�K`}�;j&Y@���|U��:�vpܖ��x�K5��/s>*u��w�s޵�@�ݗKV>-���g����!x�L�jI ��I9��U����W;�tLKG��'e`�7�����f����s~ ���E'US���O|4��L�-���n��W����:�̻��_�{QLf����^M��̣$����&�li�����a�+�����a��o;A��!]mt9����EV?�Z_R������X��Ij5�������-$���8�x&�uO������=T<_��	��\,1�4�������9�	���~�e��C����C�xʢ�W�/�w���y�^[^�f�wQ���í*��B��<T���X���0���������פ���]=:�����5���ʽ(v��pQU�j��]�=פ�#EzEo��nؒ �q��
���8!���2pT7#���NN6�	b�{޷�ᄟ�9�C����+:gh��ֆ;#
��a~z��r��<�����)p�e�F���g�	��X]$[+6>Tb��\�� �JZ����SZ<z�H���� K�Ґ 
������J9\����
L���0��"��>09�dE����y��~�Եw;�!U��L_���+�Ę<%�NL
��Q���"���]6P3~�o���5E�Y7Ȃ�E�Gt5�EL�_2SI��j,��4<K%��L'��.s�8���JTw?�YA���|h�_c��&�V�v�NK;����V�.F���f{��(��%��R,�[J2�,(1�Oau�f<�3-�y��#�1���K$Qʒ#�8�T�@��wl����8F?|�%�A����i��Ǡ*��۲�8��\kW2����Tcќn��l�0
��|~�����
e�H�c����Z
N���0�s�K:7hՁ���f3nqb��<����;'>����lR�;�t��`t��w�k���͋H[u���Ȏp��%��JO�Cu�Q^ 6�Uk�]DT/f�Z�76By&+�O9dB~���m���;�&�c�F�����򓡆Du�~Vl��O*��{���U��k��4��N���mV�t_��)��9����w���f�V*�'xxY��6	��cO�M.Q�[��8�� E~^�{�(ߴ�X�7�o��D��؇�Z�D���M�����恃P�UⰍ������z����.V��b����^��]�O[Q�����Z�ѩ"v���@=rLd�8v�4��f]�{�o�Ռ�oA�S�X8����9�9z��
Z���B�B�n����:��$N�?3�fM���E*�}�e4�Pe�7�U�*·FQ�`2���Y_�l�sY��TK���A {j�W�^����{����T���ʹ-xA��B��+3V�Ne�̰e���wt�~e�u�~>���۰�q��nH�_�;f��������C�����fIR�?�c9D���5�|�y^�~�0��F�d�\�����YWZɑ亾�J��[����<�O�Ǹ���2v�tzc�I5�Uw��2B���Ӵ���������9��|

��qxs8��[��V!@�oa�����?��á����_��y�wB a�u���'�?K�������G ���e���o����_,�Z���Z�N\��Şz��b�Z��j��h��!�?���-�$B �H<��t�Z�_@�!�-�?]��BA�����#�������` 	G ��`��CP`���}��
���������l�5��Y����������"���~�����T�r}<|�b�z2���'��Bi	Fz��������ErwG��<��z��vf
���;HRO���.��	�J����C��k�~|��s�[m�JK����5;u��?�8��p�2��o��Tƛ�- a��=Τ�̯��j�\։���O �@��(����Z�á@�n��Z|�!P�5E Ñ������?�����F�!y�ڇX��������}̵�
�������o�����--(
�C��HK��i��m�?lmi]�������H$t�U(|������������þ����������L؉o�?g��BlN���7�
w���[{g�
�
Z���1���11�ʿp6�y� ���^�mu4@S�6p��ٔ}�*:nRr(��?޹ĪR��b�=o�P��u6��x�|����#��}\��{ >w�$�K�p�H��$���w�t_˩���oዚ-����E͌O��뫗?�[�b�=�s�`R}��)��	�~C�,��mC�5N�T��[���A�n��~1��/؋�G��w3�:�[B�'+���vQs>!s��2��X�T�W�����^P2�٘���.��-u�:M��
#t����y���n{�T>#�W��: �[�0�0��In��-�%�he~a:�)
��C����3FM�Ë�����1ڄ������Ӟ����n���Rڪ!�BШ����R�,R(Q7����1�.�4�YuD�4�r��sH�;��VaJ�
��r�6��]��'z�]>%p��ZI�A0w�k]�:���]]A�ʝ&�\������#�h>��.b����iqJ�?��{�~T�|��a�?��M&�i�wNUƾb���Q��R���\��ԄzǫǅR|��L��2����H�Q��ʋ�x��&�i�ر|�b�r��
<F��˓
,V�y$��hkIW����4������_�Þ�:�FN�(v/e*�NڜC?j�Z�aC�t{l+�.Ba��g)T��2�o�M�p����
S�V�� ��`/"��w˔>��zU�>���X!�����˳�*�m+��""�q���|1S��:9\�J�����F|��C�Md��K(�(���A��r�;�q�l�J*&�����[N�r𴒜�&gߖ̹�����b�+��,~5�_�.qo�8�ǯ�����9ˮ���8S�Tܭv�8H
�Z���s�^�麬~H8Ǩj�fc�%\7��(�~e���eo�"�=8�'�w�lV��[��p�X�1���6��&��B�f�m�Ó>����M��M�9�ͩ`�\���<./��ad�u#lm>�-}��"z�~�տ F��ܗ�8 B��]��g�����(*9
|4�n��,DW�0Zk�[H�f�Z�8ti��8���GƦ�/Qå[�'�v��ʮx���O1�!f|-)�}�Mu7`_Wm_�g�E�"�JM�sS����A�U���ա�];{�ab��1��4��õ�1�ޒ��l'(�|�t�{|�Wn$�)��l|O���Si���M�W��i&Na8���P]�V�� ���W�;���"&.A��>���/���jnL�d���4����ܜ�L=�3��dZ�$L�BR"~m������J����Q	8��>��/��^����^xU7/��jm�B�|�������c�b3y��׬IP�y׳��,` �M(��zf��aTb�L�J�Cޏ/�f����sY}��kͯ3F$zh������_��|�P���O8�CcvC�Ⱥ���wZ��� O��4h�����Q�٢#k���7�n�R�b�Uzv�~����¥�������qؚ�����
�ЮЁ�ѽFr5k���Xz�$� ]��N5�/Ru��������Zh����S��ugu�|�ZOpż��W��#j�
�u�c���7�FS$SFf���S]����AMw���f��T\Ĥ�xw�<㈽*���Y_����I�UWM��������a^�C��d���3YS+�o����a�����k>?R(L�m�k����ԤQ.NZ*�x�x~.�J���p0��5���t��p�,���Q�ɱ�h_㐿�<5lc��bf2#���!��u��F�"o>����Ls�#��֨<�s�	�O&�g��D7�C��朝a�}���s�T�0�C4���Rjɲ�_#��B�=�g��#f<����Vi��\:���M�N���y�؉��WЀ�/ڍ3���;i!�"!b?쓜̳�,�� CFb��V|��:)ԜDV�0���y����F�&~I������\C�&-JW��<28^µ�GT��s��~"�9P�;^]%���$tj'yjڿ�A!g�f���8�$[/�ʰ���/Lۊ���XR/�0�q�nVr��ͺc淲I��$l�j"V��v�k���5:� �i]ߐ|-��,Օi���6�F�:��I������e�$�12�(±�y��&fW]��:����I6Clui�^�f�җ�����x�k��f������6��v�A�%��j��۠-��3n.�e�?��*�٣�p&�"����7�h���<jq�yP(��D�ڶ�%��^_�jv�B�,��嬢�N���e�68�TmӞUX��7.p�N�"
������_�����>���7�������jE�a���%���??�Ô��0D����{����������#���9������{�?�2椤�Tuqr����P'�"�tB)���PeT�_��V��(��?D�p��w��d�!0%0LUY	����� �u������|{���O��*�^����������.�7y�`�>�F�9�W�sY��v����nb�5�b����h<��c�6ib��~�ر�2�����]�);�a+oFz�^��������z����3�u��+E�%�������զ��[暟�`��0��͹Pe�5_���BYg�)�bTB�Z-�gZSD3�F�����O���t��2�&�c�'��-Z�bRv<�9�S-)Yg"�9�}�ô��2c
M p�2v:�B���w���?��F�UQ.��XIU�rVqRB+��� �JH�
��/�0�0��U�U`��_
;��K��*�V���Q�g�?���]����u��Z=�P�����R��8\�r� ��Vٞ}QB�T�ۄ�p�d�d��`=.�����hPd�~��pȚ�R�o�X�z'3�B�������.��ƴ��퉀��T#me7meۯ(�þnF'U?�M�d�A�HO�VY9�xį�.�e�<Ɖ�'����(s�f�@@`S���#����_�Ȃ{�&u
��"2�0��(�I�� �b�nV���4c��f�H	�wd[���POk�iCʰ�}Qi�r��
*<qj�^�ķ3���f

򾊹�g�z%��/�jנr��r�b���֛�th,��Ak�xvY~�{j[�Fa}RI�,>2jc�iz���&��v�h1��[���L��y�ِk�&��'�
�m��L��[w�B�U�u����-�W�	�0/�*����շ�o���Yl��?rߴ`<�!��髴GNP{ka7
�a�@h	t���{�sU���+{C��t�b�ʔ�����e#<�b&8��1-��É�s[I�V���(���޷{n!���:RU���W�U�t{B�.)�A��
* "�ݝ��!)��ݍt�tw���~7����~��>s�?�֬����9���>����vI�Yw���59�N�����C�܄yc��ԁO�&[� ���|
����}\Q�a:惊���H�,W�Bg�G� ��P-���F�Qmih�s�������5O�0�
]�Ek�� W�3����:�H�X�e�r�]9X�T,J֮��H�8"W���vS�����u/�Ռ���$��>q�����ȫ�:8�b�����s����(����P����1<
�&���n�y�o}�L̒�wC_\!W��P�6a�!�f֦e{��N�v����F�f>D�l3�K��y�V�r���8�Jsm��vmJ��c|����$��cC�偌A��~�Ǫ�T��B��Z�F�s�a�$�A}*�ӵ�Q4�O?E�����[n׾
Ȍ�}���Ә])�z��JW�z�zZiQ&H�ԤX�x�r���a�[9�lkyv�@�eX��Ip��[n�
w���~��d=O?[b�[�k��;�,|; O>�-N�֭R�ԓ�l����5��>C7�=-�K�(��d�	��A����"���܁�L�7��ts�]�U벾�ɚ�[�n���D�\�����zw*,���Ԓ�l9�G>�Z=CH�\U��ǒq�B��(�y=E�,\�Yi�m�Q��������4��T�DL3���Rvhk��%;��ĒxV����8�?�%�vw�L䗙ު�VI�<�q��	��#>�6�����L#�ѷ+�X���������N�Qn:�r�L��+�3�V
��$��$qT�Q�yVR���%��B�ɳ�����QF'-��%�m�BG��	)6s9�
�0�6�͇�}8��Y`e+�Xd�r�O;b�!D&1�"N~�&D���TR^5\b�d�� d/�
h���~	�ƛ��mM��'��D��-0�L�U?���Q��h���c[����K�t���<���Ґ�b6+Q\�7�����]J'6��<3ӯ�,��a�ߦ�߽M���5�E\�D]�T�/�,%K���-w=�y=Hvx��>��ٓ��=KymwĎ���{S�QI���C�a�̈́1��������?lf3�ng�~� ��+�
��(��j�hC�-�j��-9�Llw��"Cp���*�[����"0���2_�䊽�g�.��c(����(��<���ڰ)�(� ��/<e��7%��.E�L,ک����*�񮪾��=��דDg/�i����i�_���H�9�y������^n�7�G�hz�NDJ��̆YPɼ:��2*��E����Kt%�st)s/	�,�z�	9l}l�Y���cnV�xNjr٬%��3Ix^W�j/e���cR�q�a��#I�\c��̰���@0:N�`�M5Ro��Q�}��L�ړ6���r'��RyS��F��m>#���v�pb&����ri���\��u�+W�}
�^x���W�g�H�g8��5��II7�2��c��t~N�(U!���l��v�@�ENF�����NΚ��yv�ި�p��gfZ�e>�s4>�"��o
�U!���Jb��ˆ"�Y8'���E�ڲ��&A���ԙ�[��N
��[���
K�����U�|*.FwR�)�7�����X�)�7�LB��bd�;�
��dV{LU+��O���߸L9ay��SV��{��>�+ģR�F@;i�|��1��.k����hD�p����[�{f������4 ��_��7��̔�<�H��Z�����9���w6
x�b�BJ\�_n��t�sU���1r
E��q؊�S�y�qޞɾ�z۽!Y���%a;�C�ۈ����fS�C,X���/�L����Lr�d*���㱼��0��C�6�c[��U�1��D���4�e@*9���b]��8,s�"�mq�V�
I���;�t��bwf��[�F��%,�$.U�OZgl,Jjd�W2����j6b���F���/O�'�˝��g��=J$WM5Ϝy遂sD�ԙ�k:��_�J�����(k�
;E��k���Ǟ?Ss�g�������P���^������e�K�_D3��D�y�	D��U�s�����|�K
�.��lj�x�猕W����u��
�F�q=��0�P*�E�
��I��A���t�[����2���=�TW�_clL�AI���J3����M�PbhkA诨��f%<E��p��B-�v�o��� �tky6l�gH�S-h������l.�yLY����>�Y���]Y�����qr��Y�,�A'�8w4f:�Ջ�3���&Xhq�����`:�A�6-D��Y���$�9O&@'+r ���$P�ʥm�I�)�DYI���ګ)߶�"�ݠ�}�/�[9'T8�M�'�M7�R��Kpr��w�w��(צиY�G�Un��%+�boM�<w! ���\�X�>��1j�_ #��E�`}��<y��d%��LY@y���)��V�]ܙ�UT>�=L�Bck)}x�
8*��<�!"=��+��>��1���!n{���c��v�}1Hf牴�Y�\^���"�>�6C3ؙ�5�<D�8�G��(�H]�P౪2��,u�Wטi���c!\�ݏ�!]���m���F{�6�
�V�����Aw���[��n��"��t�/��v�@�i����PA� .�c��*�YQ��w��G>��h�'��s/��T�-�g��3H�9���M �v
F��}����'H�b��Q�w?s.�ve��ح����3f�d�_��%R�
tAЂB����#�
L��^��Էp�7K�8[vⲺ������v�d>'�)��1U���0�L��wS�N�«�Oi�ĊѤ}c;|];�8(y��h	0��F߫�xh���٥=�{Z�ϑs�C�}4|��R<o����m����3q�Z��_2#�,�)
�=4�ǘ*:����k���?���-����Ht0��ph���=��(Y�5i�ߨ�\��cN~
(�6�y,>����5�aZ�xF���@�ˤ�gh�:�f���	3�ތ�%��M�7�1Ƞi��<�/j9z��?��g%]�4	�1����i�{��e��9�9�L�����X_����^�(�� �ӎ/U�v��}�'(��.t�2��� ��Ta
- h+}�|>���L*?Oq^�.�~g�Ϡ��O/?n��.bOq>o�X�F�u�"�V�(U=�L~��.uӜ�EN�����m�	f�Y��D�ݶ听���t��#��}��B�c͵�(WvR��<��I��Yl�b��[���
�}�ŷxTc�B�)
ͺC�������閽-ٲ�2N��D����^��ԱƏ�0�hͥӊ�[x��H�-iF�a��DP%6���6�]�
;4�WB��F��'�D��ξE�39�s� 1�Mp��)��]�G�����D�y����'�-tg񹳈y t|�Aњ�o/Qm'<sT��{P��AVi�㤈(b�
<�;����c���C%'�$�_���R�?�
�½PbJNc�/N����9*"'!��[(�AB� �H�[�(�a��!���D���S��ÊW6��OsG�b��
.W���2�]~^G��Y�Җ�jv��ǝG����THu_�!F��/?K/�X�T�}{��(qf�~�<�4���^���J'�#�_�6vR)	��nXx8��aK�]/��Yt��3M�w�*��=��ֶ���
�c�{��.]�v�̔������������
�����
����^
�/<�Cz��8��>����h�m��tF�{,Y��储Z�'�m�F���{/���x�NƇFշ�?>�Ja�tY�`��ڠ�""��J?k̀jӡ������k�R���Hd�s���m&��Ñ��rF`�g��*MYTV����슈D2N����m�(H���zr��������q��MM'g&J�ܢ{٦��Q�:'�19�ߚb�z�G���2�j��4-��&힔�mM*��k/��Tb���i�t�/ʀ`L�����m��3D1^���@N��~�P�r ��'�"�l�#�h���x����n�u�<rЮ��:��%&��#�x��f��v�]�n��L�����z������=���
8%��I)�BJ�y�DI�w���)��F����X%q�s3�S̜ ����h�팞x=�2и˛	��YI&
�1�S�"���%7���$�dGHɥLƕ�G�w�`���΅ԭ��ן��`m�-x�U��+�R�S0�w)e1�����%��B��Kko�!�wp�EOϹ/y�j��ޙv���LW��
C�d7�*��������y��b�R��g�}�t]f8i�6��|��2:�ÚL��OUM�L�������]Vs�-�yte
�9�HCS�ɒpq{�໗}�Q��KV����=���ݰLW{�TD����&�';��>9r���!�5�R�B�MKU����ٰ��Rj[�!�3��D�v��G������v�{��xs�I��#��&рto����B�T�ƕnd\gvdrI�F������K�J�-{�)R/�X�9�Y ��,��5��TEr��:�J�X�(yt5<�k�}Z/��@2��&����~V�=�@�h&�Τ���*�a�ݛk�����0��֋Fte9#
�v����g}R�J�'�ǻx2��I��)r6��˵��;F5s�Q���>��?�j�ef�����ׂ�TN��1��ɗD�3̞x�@�ã�Zl�ak�B�In��˶�;1���V=O�Z������lC��Ľ��+��:D~g�PM�Z�~H�z҆�����!˲��z�ŀHdR�4�3���(�c6�����d1H�Sy��)Y���	g��IJ��rB�r�}��&�\���h'Ќ��Q��	�v�� EVa�������s+c��A���ϫ�0-r��F��hP����B����m�X��W��b���J�1V0�8j����Jv{M�=5����2.l��q��	�j��R�7�=��v>Lc��x�Ѽi���I]��|��.�1�JK���'%�_/�Ŧa�\F� l�%�5���懺���E�[����،�~�&1I�uf�.�|o���?�".�e��|��Y.�K�/_F�'��U6[�}�K�	W�.Dy��
,
�r��
���l�F_����{���L���������ڼʃTH�`չ=��
��Pג�h��C�X��|��x�Lёd&T��T��S����g�x�z��|M�`{	���wGG(šd���
���w�2�x�Ha�YX�O���녚i��16I'g��;+��Z�g^M�Fd9�ag��D �3�H���&W�H�U�6軱A	(��N�-��֒����ܬ$Q}���O}o�R2�9��Y��=L
��KF~����F���"�p<�V��4$eV �=v�	Y��c��lވ��X�HF$k�K2$iz��#*���C�N�e��'���VXи�s�8I�3�����c����k��	[V'��*/�yDsmͨ��iOd�`KݣP��V�F�<9�f\����λ�yr���}��TX�QW7��S�WE��������S?��5�D����m�NKU��T3k�9v�&���I�l�a�A�
]��p��p����p]�E��]i�ͣ.Y@���J��Cc�e��㥪R��97ԣ'{�䂣C��\�C�3R����Z���NX+�7	w>�X����s���(�>�>;� ǫ��d'�Xgaؙ��d�}�*}{'��h�Ýd5��ꘓ�=��r{O��%����
�x@x"�<`O]k�M4E�� ���	M�p����􂐭����Ѯ����C[ y�u��ڱ���$�z�AM�}�CA����*,|���ʑ�0�G�*)�<��[���5�y��6���X�ԟ#�����G�yq�db;༾�8(�T�q5ܒDȘn�v��A(�P��BxX2ru��M�csg���}Yɓk�'?��Je	W��H#�@�ƶ��@8_��>��q�Ы�j����ئi��Ee����Ԩ�����	]���ڳk��<��:2�ѫ!y�C;cg�?�n�է|���a����`|!�O�YO�$����,�u��ݲ<���	S�$@�ɂ����Ҳ�����	���QL�T��gM�y��w��HF�NY�VIh�����F�sT~�۝̎���ȧ2����䎱���s�ĭ(�gS�����Ǒ%�阖��\�75����3���@�3$?%F�R>_�̖�6x_`3�����9��oGJ�b�Gu1��;���;�!{�R}�d�b��bJ�	>�j���N��<P��(�w��wۼ�&� {�Q
v�Y�b�'��֒ݹ��Z���E�C��2:�Pl!�U����s-��*���Į��^��e��i�1�cc&R�q�-�<):��߱O��ܱ��V��Y�\����TZ���p:NkʱBd_k��=�;x�N�� �l;��m�Z�B�8ֹ�Θ~nޘ�7B�Ň�R114;�/��p��Q�SZ77
�K��9�	�VK[C}*		˷��*�_�"ˁ|�ܶ���e�!������<��٢O��
=��P���y����Z\3������fζ �&��Tg�����4�d|�b��(�ӗ��=��X9�{����N���u���%��ُ��$k_��yH��a�U�h���$ÚGl��v�tw�<88��HBGar��	�9�;�U
ںD_�%��fX�>C��(t4 ��2��1�}x*�%<{BP�}���L�rC�m���EECv}�W�~(�J��w�X���5��_�N��#�/��ҏ1>%�ܥmW�ʳ���z�)*k#5���ɞzT�4i�����eb��%K�=�C:X���dX���2Mo,������3�_�snLF���=��_�<z�rlK�4�n���4\�*y����S��õ����>��\?�g��p�9���F���ď<)a��f�g��[ m]th�6x ��˖	��:��.��5���b fY�l���
�:�Q���
Di�����@�]n��o��#,j+�\/����1:"��ꂭ'�q�	m��V�ړ*��7����m�.�����Icf�{.r�Q�iT��4Iu���δIs5,0Vy�喱`�X��{UCI!���V�&�3|Ȱ�If^H7gL�ީ͖ݞ*\�DS4���C(5���T6�!��o�x 2��&���	O�Ў� 7�X�-rPhMhu��ٞ{!t�a~�y0��=�~�݁�Q�}?���u�9�؇�Ф�<�^����y�dӐkZ[�qG���Oq�����+>��7�ƑY)62{-7��~|��8|8mƔ��^��g��
�m����p��x��_��ep��j�����m�DD��Y�3
�Gu�bTP��F�
މ�1�n%
�J���Tq�_@gr���i�"|H�'nz,��*jhj����9ϙ�Y��z�� ��i	���8]��i��:1<9�)^��h���!re>��+.0P�6r �!�'���yG���fH[�����JbX�ca$��Q�zHlk���"�^��㪛C[H��X��@V��g��l� U�Ɍ6�+�!y��c�NݙҦY�Y�Yg?1-�(B�AV���zvA���IݑP�̲�f�V��{�sl��*�\7o$�lg�����~�Db����p�RS�1�l�>zuR&3����I�J�+�m�z��=�Yדp}6��K�Ę����}�7�՝`:w(؉�i���xST<�ŖgC����uI�3}��Қ�9�|!�L����:���0���L���W����Y�p�������ހTE����&�]��e�m�c���d�
�g&�����lR�h�[@N��ٍ�f��}1�� �g��B)<wx�q۳��kKּ�k�#'��1�j��qnĻ�3z	��
a4`���X�dg��L�*+�ӎϻi��4�5�2ԕ!Ư����0lw,��09g[CS|ea(Kn������kd����}�m��ʦ��4�o�5U����OO���7qZ΅l�ˉ��/*Go?��<�'֙4\��`5?�v�<�Yc����:���_�׵^���!�*�*�>U���>�/�[+(Ѯ�������D޼;9�Hh�qN	V�;���� �(ڵ�Wu=^�
�H<B���6�e��펩�T�m��|>�Q{_�B��+�Y/F-��
��2��ҍ>�����:|Eu��~��v�������tt�7������@f&fJfffzj&F��. A)��4f�����D{�[�j���T�
e|
}|".|"6P�wޤ00?��ꨱ�A����;��ueUE=h#�eM\�fxcs����RQ�HY���o���?��辭��ݜ������C\tt̔LԠ? �/�������d�i���~9 ����ed����j������	�OO����_�����=����)t4�L-(��L)nf7���E�U�g؃����g���GO{s�����23Q��1�ii~��: -#���|~��?���ֿ����h������30�������o�?���t5��^������������zzZJz �b�g���g�� 
�z���_��j���M��eR(���"����>�B��R,E#|E��7�7��ѹ %R[P3QS��5>h�p���U%����(��S]���Gڪ��}���yڛ�����;��.��L�}�_��LU�s�n���A������_W�O�p��������\����Gr�@N�ެ����4L44@FJ =3#��翁��� sO���/
��yy�_�?�O ?���᫯&*�}���u ?�Wt" ����~G�E/��S�\�{^�����������٠4֧��.���>�� �BE!��{m�
U"8�c"F�K�.�\�	�k�v�����܁�� ��ȑt�����nЍ�\t?�
�!�����c\��E�:\�\.��;PH 
9��j�{ų	��*��o@��@e_����  h{pb��
�@!(Oy��u�	8$`�*c�L�q�  �DA��|����G�.�A�Sy��]��9�닶��)/ܷ:9��t: 0��ą.�
��E?�_�l�o�9�:��! bԦ�1(N�?Fvj�t����`�C?`|���.�G��L�r�|��e������yȅ�@�LqrY^�J�"�h'\�)@Ʌ����A����?�Ӈ^���+@�M^�+��u�����gWu��/����'Y�!���ͺ��TW���_����k�/u���Sx�q
��)�o�b�u!��w8�a�Uy�~�g����Bf���&Cr�_��n\���;���re\ڇ���V�h���ɗ��e�~U���x��?�Å�p��B��[~���>wQ�KY?��侐��\6g����A��}��rJ�[~���]٭S����O,%d#y��ve�S�@���������+C���� d;i@<��@e����d��2>���L5�
.���������G������(48=?� �g��nӞ���rPxv��� f%
���Æ���a�n��s�k���-v������] ��Q��<�/'���M�.��ɒ
p9�����v����6f�%�՚���2���/ԏ����sI�S��?�4-׿l�o��e��%�����\��ˆ8������	>����j�����Pq�O��&ŵ�j_������k%S=S|fJ:Jj
��(�-5%5=�w�ߵ��~��8�_��?� �����������������G���#~�q�#������K�}��p�ۏ8�_�,~���#?∀���H��G���(��K?�٣��8��������u��;�@�-��v��y�3.}I��8y{i�nO��A�s��������~�E�������~���ڏu�f��������{`����?����?�$�x�o�
����?
�?�b�����aD!.�_�m<�E�~3�/��W��*�~i�� B|����o��R������������|��w/�\��w9n7�����̯������O���9+�ߟ����ً����?��~nd�/�����9��ǫ�y�2��=���o���_$.��g�K�������\��^�S�{WU���^��<0M��f��I:!���	���@�2v�$����I�����{Գ8��Lp�!����u���]vDş�u��,��;�!�$<�i�{��{��*@��̜�Ӣ�V�{�꾪z��UǨ$/c�k�8��"���Gbl��G���ģ��e何���
��W�q.-Q��B��ee�˜ev�KW;W.[�T�M��Z��C����Q �&��p��MM4�Z�ǍVQ���'j��\ͮ(���"Y�1 #r��%rPHM*=x%/�+V���c��9�>����2��!y\��Y�gr�UM
�)�D5ɤ��=K�@wUM�ssSu�.I� �Z�y!H��F���r�ެ�ǇuR�FP�jbPfӖ�f�F���VC ^��A��

K3�]�"9��jr�̪-����͍4��Ʀ��z
eoQ��U�ݟ�1��
�N%^��3U*����Q�Uyu?G�3��s�3���^�J��>�oC��1��#Ŧ���ű����aE���OU�6F~j����]v�Y��������}Egp#�����������x�=�ɫ��}��n��s�O����t���q��ݯ/��q�ɡ����ߋ(ZǝD�ߌS~��@���q�ƫ�?��MvY�߄���Ľ�~����A�-��B��r���)����sJ���_�7*��W�?����_��s��Y?Ɩ3�)����β�w����'�����&�#F�í_^���?��O������7����y���������E��7<�b�����Yr�-�b��GD��������_���W������m��?<���������#3������fy���z��+-��$`�I�wN��L�V�aّO�	G���k5&ˎ`%nRҴw~)5y�W��{���	�+�t?Ӡ���sJ"q���y��)��T�&�HY�i�.u,[��	�3��$��L���ѤK���9�|2ֽg��o�w����U_�^���w_������S�E�ܗ�y���{J��}/�id���UW�]�%������z8��?�|멡%�ʻ�������[�9������N\�c�9s��o^�{��&L�:�0t��.d��N��R��p�}���K8:���9zG����8z��kuM�*���5V~�����{7��f��{�.1
�{"�7�=x���I&>t��ODh&�A�D|P<���p�C|��O|��C_�c>�a0XL|��ڈs�"�CÕlC���=��?# ��n���K��fKл;��}Ǳ�o�p-�b���j&��	1��L�ʄ�3�YLx&Nf���H����> �=>���/��^(#`��{3���D���G���apg�1Z;���'C|�io@g��LO���e�;��/�@z�ܗ�R��;�I���e�)�����������YFH7�&��?wK��Mc���^Rl�n�P�1z{R�PVl��Y�$��B�PIƐ����9D���,ɯ}@�����O�N�a�ޏ�\��I~�|�o���@�������LY o�Hɢz0j�dIe�~:,bh3�)����$�=D�����g���:��������`"zu����/��̷�Y��[��[D�b�w(y	J=�4ȫJ᳙�T����]l�2 �TN#67�0���0q�/��o��D�V�i5`�M�`S"{���oS�"AYv)6Z�������^�G�������x	l!Z�HP�a��o��bF�bEw
�{�6*�I�q��O]
��JY������	t�J�|3�5��Mz�B��밦$k���&`��SedDQ<���k�s�e�G�x	�>��r8��򚄬��(>9��A<9#�$���t_������l�z~S�>C�����X�7��(�y����tJ�rN�"lar��C��'�x!I����T<M��o�Ӆ�8u�j�V�-tʎ�'B�:��t���M7��{�4�YHѩ4�Ix-B�U�/BK
�J���Y(B��O���	�R��!{,��`3Ҿ(M�j)���>��tuw<B��+��.u�j99BOѼk�zJhTi��Eh��8�#�4��y��z֜����{"�Jr0�%���>�G��KO��'ʴZ>�K^��G�{��ZP���Iw0��JcrB�|�-2�?��E&�����WC�gh��g�r�D��[j��U��L:9�#s�����X0-�Q���ب�߉�����OBq�&�W	Ӟ��֊��څ�Pdʳ��
��:g��N�c5h�Qk�ڳ�K#NK�d���K�*i�풴�E��k'hӽ�Qz/�>v�k�O�k��e�Wbȇ8��	Qz(F<I���q��������>�������X���8:�`O�xG��$�-ۓ�	���WD������|��ݟ#8�����<.�T��æ�[#P{��+I����nc��k��(WE>���o��k��'9�E������¥�2�%��Q��Q����?#h�c�Ca�n�E����YG��w���::����r��:�>+������=��
���7p�^���Q��������X)�&���%N�J]t�N����8Z�v]�O�-�g`�1�x��Z(�,����,�����J����^ʖGLZ9���U��U�˂`y���GbZ��<�*6*�:>v\`혓-*ת��e�bj�1�����VMk�B[9����Zc���Wi��Wc \�1�5�h���`��L�SU�5A���%j6nn�~�5�J�`���Y��U�g�Z|�
U�b�Ț���f��c��d-�:��
=ؒWe�9Ce��d햢�kl�,f���^S��Q�Xl(Y��>6_:A�!k@r�F��A��
_��6��_�v�|;L$��y��V�3X�����<?@���d��7�2�@?V_�G�:�N�#�_2��R��P�_Q>�6�b��I_'���A�'hq�j��V�����#�=I����f�������(O)����b!��m�1��N0�Ez��w��Ⰹ�/�k�ĝ��"G�����a	��&��ӏxL� L�?э��c̈́���kx��k��{VU?@&f����llp5V�G�!s#|����+�?�rZ,9s�+7//�:��[��,Z���0ǒ�����������?s�.�f.�]���(��Ɛ�޷�V�׶�M�gVn�%����<K������<�Ȕ~;��,C�9p�}/G��+8�㧭)G�:p.p�����
$���;��. ��_+r�k�:�@�f
�����
��g�,��n�������|����݆�G��l���\�����i��R=Џ\(�?�^\R|���q�'.��%�<[�{g#����2�@���v4�1ENg��9������Zg�7=v��b: � ـo���K�VYn9�%�{e��P����QZeEZK�}�d~<$���.��p#sY��3/��z��.�G��
�_����!�z��!�l�xX�w����L[�#�!�몀�O l�p;����~o�p��P6���4�1��;��
�}=�78��X��`�Rp4n�=�>�O�i��.gJ�AOŕε�م}q��F-�t{���G�N����wv`�t':^ q�cJd-}�����Z��ѓRDK�h��%��N�BY��>Г1*�B�C�h�T��ˇ/�X��H�:���l8!A��Vi��?��h6���	�7�n+��K�s�/<��`�	O��&[<��sOw= ��w����4/�מsx�sB��v"ڧ�Q�������ޔ#����*iM��o��[��`ikF���{����<=��}��I��|�~�O$�xm���{��#���I�9��_¿)��<W�C��'�����-�$,�㹸��fx37����lX�ir?�U��r��d��5IPڶb����k�8
9>:�����(��
�?6�]�K��ݓ�'��.Ν��������q3��,�h��dy����,a�]�ܲ\�'���~Qo�y��Вl����"�̡`%"�"X,�ZQ�EXd�"Zg3�-���!��ߪ�/��.	���E=E�zwz�!G��<D�E��1�����e�a���T�N�yPˬ�"��0�s�F���W��>�y
`��A�[���l�:O�RZTC�L2�1Hش@�wz�W��������-D�z����%���Xa,��~��w�w����{�rM��k�F�DY�Xb�/,�W���
'���Hv(w��).�6*G��!�oq�H���zu4G4���$w9"`�ɮ0��
�+�U:
Kf~1Hw�#s
�y��������9�t�!��{0��[T��)�c9�	|
Zb�(���qC���&٢����勉����� �K��@<6,�����ρǪG�N�)N��4jy=e�DF#o��x>Pp`�6�I����]Q2S�����[�j������mP���z��d�����"�"��Y�B�/W�W=�Ǳ�Slg�2�"�B}�?È�Y�s�K|�8��e
�%��u�W��C�D?�F���M1�J�D�E�C�r��o�_�V`��[T�����.�i����Q�4P_�_;�~=�L�ر���im��Xi�e#л�$��B}]c8��n_i�9���{94�n;Kl��m�/���=�R��)��4�Jd�rm�U�4�K��o��$�����I�,�t"����*�f¯&�%��0�L��-8O$�m(�hb`U�om����9;jyX���^�py������K��`(��#-�VP`�W���'sY���%�������������fdDdN$�1�C[�~�9��� �ۖ��5uk�M(�p9�_׃��Kd�u���H�fU�y.
7Y5��*}ܢ��7�,b�e�z�%�%�G�������ƕh\e�~��r����u¤�m���֢����D|�0PnA�T��[(T����+���~�/6#&�ۓm�_����d�#"��tK_6X�jk��x�[���M_oj��ؚ-�u";)0և��"҅P�+�y5ܘl�f�.��C��T6��~'H�K�q��Go<�/pR}�������|O8/�R�ͤ�5ўg��H��@�j6��
����M��6����� �ގ�'l��.���\%��|U���e�
�DY�3�wD� ��y��.���ΈM�:P|s��U��+����oZ7�e{6ն���$�*v*kWmȃf��d�"?�:3�����O(3�(��.��Ґ�����Ky�ҝR�-�C���K$+KZ٢x%����	����!/��w��sA׌F�j�rA�����X���BD��ł���W�lO���O�,(��_ޕ�xYj��炪ٷ鳎f��_:�e�����*țcyu�����ze�x��*�e�Ϥf\��e�V8?�����p����p��^$�^5�{�> }�IDx�Yĭ�,� ��۴����)Y�@�N��̘�*-d�>�f��P��;&_֙#Kֻƙ[���Ȓ���\�韦=3W�fӨ��;s\)y��b#�(�.l�#��
����P)�Z0� ~��%�Ή�O���� >q=8��<AF]" Mg]��8�x�5OPƆ6���(}%���&�Y
�i.(�z�#�
"�����*i8����/�N��js`�����8�Lib9Uk��.-W�[�Fƃlj� bj$KL�maXU�!��;_	o4�4�3b���hk�g!b��m�yh|��5z��5�É�/fr�e�y����#ҽ�aT!��w��wlP���`�r���`sH^$w�[VZ�`������=��=ሙ��:��p?��ØV��|�z�yk���T)��(��
��W��tN�gQ����N�;"����ij�J5�d�OK�F�%8	8��Z��
'1������}���׳�t�����, ��	�����ܪ�z�n�z}d�ȇ��k���&��v��
�t�]��bX�t���V$�)�}�m`�Qr�-���)Q�V����2A�Yh���|m����I�$�4������=p_�|X���ڕ�5+=�f����E��Z��]��U��x�����I�Ql� G8��(�"e��r$�<���}�G�(q����+2�j�<��p�V�9����m�#�ڵZ'����yw�(V~���U���U[�u�(�l��uhi�F����O�KT9�9>��>�)�	e����h:M���M@�	��1�$K��'��'�A�
3����m�hV�1�$�"�nru ��#��{�)�f� ���L��rS<��=|�Z(ԭ��,:����Z����I.��)���#[��7ȥ�/��,���.���e�~ny�4�|�U�H"�ޫ�,hy��I�t[Ն��C<2�w���T'�б�8'��3r�`f*!��R��sԡM��N�{�<ȹF�<�p##��E0���]�/���~�
��T��� ��gK�`\Z7I���MjD	4k����	 @��
���]���͂�`Ȟ�}�$����t��Pmq}�f*[�Wo���1�*;��c��L�����JfB]�4߆�@���X����b�3�g��ǁ�]Y � ^�w�l�rRʎc�k^�z�����V�y�i��wp��[Qͮo�����]��5>�]�z"��m���ae=���+���k)襤Q��1(��0�la��%�́�6K'���$��<�Id~��yǗҵGi�����x��4�4��Y���U�(ϥY�����p��g)����� |?�G��[�"��>��}Y#s����#U6<��O��wK��S��2�y�T�T�If��>o�O[J%i��[���2\����QZ���ϫ�����C[J&� }�8�W����?~�^�u�ѥdR��z}��>*q�eL;Di��7�����	�.-Y�$���Qp�겒c�(ӱ��C����^*1�
��{7��?�1�ɨ���H��:�sNl���4t���,Q�G|�\��>��L?���#��e��ڦ�B�sߊ��pv����ܻ���n"<T�E����nN�XC��j�R�-2u��x�	 u�: �O�]J���pv�B�h0�} ���{�G}:qO�\�H(
}.d�h��Tb�!�R��b��M��hK�ʻ]a��(r
��?�̪�([�d�DI����fW^����0�IsN@q�OqA��9t %þ��� �l�&�ɖ��Q3Ѽ\�
	�?��G�Q9A/�x5-ö`-�ϗ���������V�m�0����5H���>���[Q�v�~�悋wST���`�-�S7�t��y�d[39������;)��B�7�����&�j3xؙ�Y��j���Jښ%h�v~���x����nEmO���9��Ȕ��]����98�瘀��m$|���5�	
���M�ѿ��A�(��'��`�;��=
�^� ��/9
0k��L���e�T�Y�6�}�X�m����n�}>�X_���Q����6�$!7_`PJ��q��?��,�Y������hX�s�}���)&ң-�.��9����$|zI�4Ve�'�
,?��/y"�zz��=�<>��c�CN�i�Q�I�n����a��������3��R����p��īi����"���OB*9���H�q�Iw@�p E�׌�
���#&cK�d\AT[9�O� ��I�t�����!�|���+�xi����{C�7�Fm����lg��/k�	{��1σ��zw�y�Â,�?�N0 �!
�`���&r������ ���b�F?f}݀|<���8����K���>�����	8�J����~ ք\Ic�tҥp�t<|���/¹�2��<.��0�AUe��
�\�\���u�^篿]B]�
V_Z��$ּpe(��l�B��0>D����(X�Y�|��U
���# G��߯u�>���Z�Mx�.����>��~)�'
~pV�+B�Zq�󠇡�� �*?����x����)�C������V��(�;��f�Y������ ��(�k��}�Af�/2�������O?܏3��L�����ЁQT`GT�x0o��Ǆ�<ՖR�t�^V�U'����7�}N��/;	63p���ùj`�QP`��2Wq�.#�%4տ�H9@��=DLn�Y	2
�>k��FX����\s�1J(���uk+�5�_�xqX���	�,�i����O5V�jJkѬ�n��
x��(���UV��}M��&��v�S��:F����<�)j��aM�����;đ�y�!��$��k�h�!n;�O�:d�Ul�7-���L�v�΅u�{�ƀ�>շ�#���Ǡ�p�Z���2���Om&`���u���l�iFX��CtI�����;X�8NP[��=����<�����B�����}��~t_O9�hF��^�;z���b���Q��ῲG���r"q���M*�h���l`�*�����̠vj�c�;�B�n=�L����r���Pr���N�+ĵT��<�/��8����{��Fi~d���
�i��1��N���k�>��uj�:�{�0�Ȧ��̋� Ϫ*
%�;nDI��荣gi��oƞ5��u"K�����E�^G �o2/�1���M����o�T˩.Q`�ɣ40���n���!��k�����;��Hl
6����n���ti<+Ĺ�L��v����Gr�'��2�<bVЦ��҇���4����"��G��U�I�~릛����q�hNf�+v6T�jR����N��h���Q2xn���n2����rE�)Ћ�H ��-�ikէ��%3圸�U,�7���ř.��?r�|�{���V�Y����((�6���cw�M�5�<TcN�jf�l7-B�\2�I1&ľ���~��Ҩ�9����z��u�u��/��ak��Z\��
�0�e��"�t����LNIJ���ɠ$�K�v��K����R�u�nB��.*%b"If�`fX�lQ����N\�ӱh��l�*_,��wbݛ"�P�W�
m���N)P]:W�����9f��+���>�yb��J*��EO<�D)��T�1�|��G6�B3�@;j�P2��9(S9̋��W=%�:�9<z=_k5�,G���9Bl�da*
�����+qR��c=�1�[|O�6���u ���9���o�
ɣ�(4&�Jᴛ�d�.I�r*�l;\�Z����y��1k���Z�#&ô���;�,~w�� h�ͫ����l��;���h���m��lI�(
Qʥ�=�>�g>l�c��3S��r�F�_qr�A�����F���-����\��d��TV���X-����	Z=��q�N���n.�'�c�`V�f��B��&�%�ӯ7x]d&[��e�����>��G��
�Ai��H*.�!�m�ǗQ�PK�5 �4�?�qVF-h/�a{j&�bA���;�i��h���p�62���[S&)�<E��`"N�{���DӶ��H�r!�w����)sP=����]�����;[UY�����L��芪�
�G¸�K��Cش�����o��VVA��JnJd�XL�ϫiB��$��b|ޘ;�����J������.����C�[����W����߫�����W�獼�S{��۽6d�`���"�FG�=��3� [�h�*p���ha���uc�{ed��C�l(NA�]�'��*,���*�ns-���r�6�-ǹ[S��8k��nO~�u�:q/,^'8��/���4�#>B�y���1�nm*#.�rM:ML��ڴ�����G�ww���ߡ@��W����?�Gq�;{��v���r,�C	�΅`+ȝ���a�Y�቗������$�_*�S���췗Ƚ��KaUs^�Y���eI��Tb_�U
R09�ѷ"��X=�R>��
g+D�tG^��C!!�v��ֲ"������sU���<���-[�4_Z���CO ��Za��|�V+��K��Z�n(�fA��؉e��wA:�Rm�~U�c�Z.��c��4F[��.�Q]s�
z�o�D}ɲB�+Q��$�9�9����,��4Q�m'������4��W��Qekx������x7�������R��=x1�{������X���gC���Gؿ����2�s�� k��i�G1�݆X	]��0�z�r�z��u�j��3 ��(�˟F�].�w��̞!eӆ�H�ȫ(�ʎ�U�@�̠�G���P�sw��h,�
�e�;��2��Q���+�H�������b���+���+ÛtxWcy����#���3����'��O����Z٭l�Q���J8��w�BX"��㻪?N` �d6H|

spt�2��^�
+�?�����(�ξ�������\��]ڇ��G����' 5�%v���Zc2H�i�X��/$��;NKY��E�kĳ"����P�'@�/�|��?�_�N4e�>��ɫ��;���c~^I�?w%��1����q=��GKi���Ğ4Mq��i{���{P�ށ[��e��}��5���7.Ā�A��_v�c�6q 8V �'ж�~
�}~S~X����f6������/	�z�[�J����q;l��y��L�q�dk���Qb��.�o�Ÿ�z�������k6!�r����39Y��|ف�I��>C g\�]����-�Ӌ��>�M�����*�o�8�E��s>��j�s:����!O�'�3��-���A�
v;����
m|7��m.ԑ����x�3�m�{_	�6c�O��
�6�3����V�!{��{�}���`�Y�a�V,�/�����^?����g���(��*��_�o�ź��N�E�HleT�̿3c����8Ekhq+x�d�Yit����?>\���;�ab��?��>\s��s:����Vv�a+ȑ��\Nxf�uqR�QχU,y��ӓ�b�15�9W�_oH�	w������wʼC�}�.��DSs�rί�^m�e���3�*
�;�i�LQi&���O,��;N�r
��[�O��o��y������E"��D�>r����[� �|ũG��v����- ^����.�?a߯��{��IyB7�]3`�Gu#s�os�uߝeuw����:JHf�\C��k"������%'QJYg��s�* 1"�E�ѻ|�������G�Z�f�
�T��k�o�l�IŠvz���(�9���������tgG��=�I �̡��������_��wƠ�f���j}�2��������ƹwc)���{Ȇ%�v(p�.�JXY^�V-� �c�Q�ъƬi
���E� Υ�R9�~�@��iO+ͣ�&*�����'vQ�.C�x�$,Fn��~�:�l���P�]��G�wEi�16ˎx��4���J*�' z-�A�6�G,�&��߱����E{]�#e���a/*�Θ+A�]��Nk��"�B��]]��xt���X��L��Z�z�?�����,����bPy��.&�w�F���w��?���u��ᑡ��+�ϼQlꅅ�Q��+
~��k�U4.�ʔ��Y��Bjc�=Wg�nR���~j�f��KpD��RD�� r��Y��#��n�lC�>�_#���K��,d������u̓v5��󎴇���kq]0ǆvܫ�;�FNN����S�?�2�E�i�!c�AeT�<��ʥ�Norj�� ���M�~��ͻ�J���'Ϻ_/�\؟Yy�O�_���Qբ?R�1'�2�	�3X���L��ݓ

�D�dl�;4���
v���H����=��|�T���9m�<I�([v	d>���~ۆ��6��m��X�R]̕/q�P�{����
ܦ�a��!V~��X_�m�{�j���6zN�[B�N/q��YY�'��:
Syӱ�G!�
����
���\\:�՝�<>�
+�kIm�`ӉLb�C.<��6<�c�w�[b��MۢX5���BF�P~�������f%�VPw:▕�fk�;�y���eeu��q�;��G�xp�6�Og��L�m���1gu�8|��Z����)@F�ӞtpH �ٮ�.WC96��y�`�I�� ȒQ�0��X×��9%3w�N�qX�cz��b�-PE�mb	��t�M��f����������3:�-�)r���*�F��ɶ�]0�z�sA�����z���
��ލ����*�{_�����3�W��nip���-ʆm(pK���QF��u���<OA�,79����M6"�tϸ����6
���l�KN�xz|S���v��l��� w��,���6N)��e�uf��s�:��s���))���3:{��<��\�u~xRtY琷!-)�l;�ٜ&�\�*2p�%П�w/�r1xh��+�؉c�^���Tئ��Ǒ�V8g�m/�c�!��2|������~\��M�90N���u�E;D�A8>��{)�<н�E@ш�%��0~��,A�=�=�
�x��������7�i�8�,+Җk��f�_��Nx)u�
��OOuQ�$/�,mztV`��y�eҋz9��x�ԗ4�B�ȝ������F��\���J݉B0��Ǻ�=G<rUC��D��iC�b�!�x�f�G����ڬ@+�NLmt��Px�X��+��Rڎk�mr�df����a��^@C,�����Ak�����Lp�-��2�5�R�M-Ƥ�"Q&(x
ڂ�@#��Qn;��;�������S������[�2�o�ǘ 5��6r@� $�@�lw>����WKĽ��X�}�H��y;��� ��GCN��d$_�HX��e�j�{N��n"M|��7�A[.�r_|r���z��ޤ-��S�4�Z��m�X# R�ÔM9k���Qz���%31w1?�)�^
{��al��ћ4��췷��<#e�?=]�U���xT����kDV����������^����Opn(�\�6�R�9��%.�~�w��{�;|�\�<�dX��(Te;?|�m����%�w%�X�֧H��58�J�z������~�����/]������%=��������x[��!�����?��<��J�y%s��	���P"i�WW�,⧞�8��z�F�|�IS����-)���[�Wz����t�ލ�nIz��D�R^����&�z�ے�_x��:�M�v����x�iL�M>���U+�G���{�C�+-(y�c�a�冮�s�9�ZQ^l�����=�8F��nO;���
1�i)�v��2�F�8���������!%3�wU
�ʨ"���b���ӊ���[WX�=��~��kK;J��(�IT����Ch���{Pw�S�n����j�3ȀZ��D^x�|`�bm@)ߎ��JT�d��7g�.��&�6g����)��M����W4���Gޗ��k���.�gt�����DU}7/���PL��[ޑ�)
�Q3g��]�m��Ǘ���vC��7<�|���hhׁ�Ç����Q][��P
��	V��(�7$ˡ_���[@o���~�k��2,��X�&"�����w�6��_���*bF���@h�o��nu����!����*�h
���˲'�z��\�
��v���
*燂���	^|O�r�o�
��g\�l� _?��<|}��._�LfN�y�2CɦA%��exfʦ/~ئ�B�Q���ܼ(.���J"�nS��/W޲.TzB�I�eO$�!J;�%v"~~�1�o��%�!�(���m�J�8s.���t�L��7���øi�Dz���6y�"�YqI$/�Q~�#'�ݲΫ6�3Κ>�R�-P�au�{�q]�X�N<?��|"����S�y��r�y�f��jo���۬�ܟ<*����	�G��y52$���r,U�Z><��m7T��-C����R���aI-!��U,�W��?܀�"1?LK��-+���s���F��<��	AL)���P ��D�^>�����3H�jQ�_�aV��.G$�����g9�ڬ���J8Q^	r����y���c�:.s���-�@�Z��Tɀ+D��q����rSlys�<���ɹ��{���C(�xX{�tY�[GS�pF-/>d��T`�ft>~T{#ʔÉ�9�(]� �E�>�;�7T�E"�SolSLJ���p�2��$�>��9W�j�9ޓ��=���.v:��nD=mѣ=���?��V�<J>c�:��#*�A��8u�Ͳ��&���ľ$x���� �0�:�4c];�S�o���bI#��
�mn��j٦z��淚8���.�lf�`��`s�)ڋAe1sF�v���)w�TL����ۋ+?->W�����q��'*�~�Ĺ�A+�e��e�WT.�tŹez�>M?��]zЏp�u�4����t��9=U@O�s�N��/�bm�1��(����'�_�.����£�s��}eP��/�	�T�=��EbJɝA�T���X����c���,3��DI�?o�Xʹt$J�d�`)�X�O�uP)I�?�XC����C/��Q�f((�Z*m�
zϊ�(��Q����I5����c�E�I��J�'[&���3��q���#�:98W�jقN��ʖ�綟"�D�$}���xz�l�[°�O�Z�{ñ⯪RǠ7�wl<�5{�s�@�ܟ� k�t��Íx]��V� �jK��0�ga�
���n<�?>��Q����&��w#nh��{Χ�Y}h�H)uI[��	��:���|W�.���?�9,b�Ԛ��蚨����ؽ�J'#^�&��-+X�p&$�����HGɂ��6Z�����}DF�I�����7XRw�Ԡ��V���=���jm)�sVK��; ���Q��`s��E�[�7<� ,݇�_}�?A���QO����c�]���9��,��������@�	�ݭ�x��O��H�@[��#s�9���3����eh�Dl��*�7��j��pT�M�<�+�����-�,�ׇ ��p�oF	���V��~�睊�l^-Q���d(=�T�?W�z��~����~(cX�ٯ�Ynم1р	��:�5d�jo�$�ԧo�tt�+�V[ߟ�����9�5(���Wt����l���YA'<I!�*ã��{l(�h_aU�v"-
V���[���_?��Q�F�u��-�����=�rL��#����!�ջ.�D�������%�ڬ����/պ�V�IR��-`:�܋�H��V)�U�2n��?��%z�L~�ä�w�o�y[���Ʉ�����߷B	˳߰�DJs�n�o����v+j�y�
��i�~,����f=_]R�
m>k���W:��8�Q���M���p�Ք֘�u�/Yu�'������R�a�:�A9�J���dI�;Rv�,���a�X<��E�e�S�1Nz�u5�u��1�HAӂ��,�s�攝�~�T�#zspD>� ĞR��Y"c��E��ȒŚ5�~+E���J����u��	u��D�W�9�^gME�'ʺ�$J�uj�{@MJ�nVr�rW:[���Ʋ�02U���&�M\NB�cˀ�%��j*�����ƈc�{��>?�_�V;�M�U������0����t��F�E��䉯H�}�Dd��'Z�[�M	�����r/���I�F)�VuJJ�WB���V���l����
�������� |���N�z�ҡ��t���D�K{�l6K�w�H�f�>���ͫ�`����wp�E�گC��,:�
������Խa8b��\��x��R�R3��/�c�BIe�Uo1�-ױ�=����RO]G�X�BvűQ?�i!;��X>�~ݵ8���=
̽Sw���>�w��!��d���0���o�����F���ml�/n�9����t��L�/��OU�y����˶`.Q	`��؂��l3�W�F	�]'<3CZl�X*>b������1��M��n��κ���K�H�Bh��c
�U���AZ��m'���ϝ��ط�\��������d��WT��U���X�֐F+ dpK�&+�%s�
�?A����!����H�w1�םr�;�����M�.}��P�b�K�^d�C��b��7c	�l2�������U^7��AkB ���#�	�u��G � 8�){��sR|6M�m��څV8bi]�R�f.�!���l���		����+���de���J���Od��	���A�M�u+!�-���J/��w�\�~ ۤL�I���S>[}Ƕ�V��o��V=���Ey�[��#~�raK���eޱo��r����v9^�8r�]�Y�|௡T�M�b�'��2s��:K^�]��k���������D&p�.���mMٵւ:Z������X���Ⱥ=&Y
ඦ�� ����f��!�Kx�u�H"�����µ'Z�A�BL�*,o&2��>0=pX�Ԝ���oQ��s��*��GX}K夣ׯ����^[N|��8ٟW'���k��C�_�_5��E�_ȟ}
��J�y/������0��[k����^y��OU.7�eK^=��������T/}�Ϲ�����L�uG�7e3���6���9�-�E�xޏ��
=�*Og@/B��o;��v��н��*f���_W����$ڤ�ೞQ��z7������'���đhP��f�����z�_����XK��?��u_G����ګ�QW����]���piY҅{����a����Qǟ�Z��8�-kB]���
t
J�nWt��-BU(�9�4��-��JC����@�{\��g�K`������3��e�=3y.]ф�H��^�~�>�;P׊)���}|�Dw����v���/�"9�H�K�ͧ�ة�!ŕ���,�x�JL'<4�D(�	�B!AG��n�D;X�s��U��~ЎF�`M>"���t7�빾��n�jY����m$;��w}mC�/6kx����Gm��^4sG�Z�}�{�z�+d
�����>j_��`�fnz�#�Hg4GO�nڗ-���?Գ ���{���<i��H��aN�s
jW���}��5���܅��[�'n�hF��Wf��.���u���@~nQ�	�H+>����������3�X���
����?#>k���G���d+�|qă��8�t8��~�,���:�?PNL��R}>�5z�1Bu}�L})F O����9R���TX�eܲ?{�!��a�{��]�.�E�Wy�����JŞ�t̯/AuX����X}��
���7�}Љ��ޘ&й���6��̬� Î4�_� �F��/!~�O��K��DE+����z2�qts�|����j�>�4�5���J4.�5��"JͿ�e�܇��|ʽV�,�A���y��m2RϿX��D������EҚ���C�_!'~/1F�q�=�����#��L��(
�Z�G:	"����}�<�T�)�$�1�$�)�w@Z�{�"�|�j)�J��!:�����DE�x��AbU֠:�+ _Ǥ��P����+d�$6��y���tA��������^�|K�ۧ� �[���Khp/���Xe5�G`y�PT¬�(�J�{aV�W�����&�g�H�.��&�Ccgt���Z�h��~��M�wzIv�}]���;A|�D����ߒ�v��u�y�[1��h�j����__g��җ�v]���.�@�?���ն
�S��)��9��]���(���zpu�u�*�YM��������YE�b�,�|��'$�Pbuv�҉���ɠJ��ܛ�2���� ��Ic+�_�������'�Y�x$�ytJ����<
j���y�G֒l�#w"~S/�/�)�6�	��k*)�eVH�{"����wd�V�$�q��L"G6d�^ީ���h�}�P�b��J�<�@��`�e�.4:�%فVa��]S0h0��z·X}��r7|l�r�eBCk�o�D�c�P?��\�c'z��*���3n�|���,~KV��Ͱ���T�s�>�Ŀ8���^��������^�)�x���jjI`�/��+!�Ul;�%�\�ߩ���{�{�Z�+;��!�	�,�����ˮ��߉`A���z(���ۯ�v#M���#�7��&��.,�՝g����mE�b���Լ��vtn�������i����^l����|��x��	��Ǵ}�0�D
��� �r�� &pn�������K_�8���(/?R9��5����C��(翺}>l���������%�`��|u��k1=]�i6��z��xI�+f|�o���B@Z{�սV�~��U�|G��ɗtU	c�@l�����-B�ه���^�|KLH�V�Q]�~w���[.���g�������#M9Pp��?����C,~�_B�#�e��@ڃƖuJ���+��tN�������99QN�g�?p�k��Mh6A�	/��TϢ���'o(�dAI��v�ŷZ�X�ro����ߞ}iķv+��6O�2�z��A���UR�ň��i�0h�u��7�x=�s�[8z�V�r��f�2C����Խ%�'�%҉�Ni
xR��}�
�v{�>�-[э�:��b��%w��y'����6����p2�V��9�J^��>�K�c'N�Y�\λ.�x�ѣ!��y�F��f��}.T��}�e�P�+�g��`���d@1K�p�Ӭ����Z�ɚ���(������"�V&�v{���<�ߛ��_j���v��������D>�7�����)�H�,�5C�� ��Y�yϜ,���Q,�3:����}�e@�_�K��O��c�_��9��9�4��u�D���8�o�A�'5*f)�Ǽ���I�6K$vb���߁���o7G�%�-oAr��_;+��!>�s��7������O�u���!ī�����-���Ҹ^�	��a�c�o����݃�4�n4�z��!v��M.����a?���%����!�z�ˀ�ltH�?Z����T���,��-�\xߡ5����d���[ڃ�U|%����GN����ȫ����6<�S2���/-�vg��s�2�SM�3�~�;k������of݄!��B%�TܲG1I��Tm�*�Ƙr�f������;�]�^�E��k���/,�y�z���U�|y�A.٤�6دsZް4��;L�����;�
�Z�v�����,�X>���Ř�xBN����������LP띖�L�y�(ӧ2��S���o�׸��:�<j�pK-�>��w.F�ul��F�����2WDRP�Y���N�UM$l��p�l�1ǲ�5?�j�Z
C�o0�)�畲�w>n���L:N�n7h��X��S/)�`_0���y*$��=�t���*%��h�|���!iI']��Af?lP����n9Sr�df��M��[�Fs��Z�kb|��$�x��CS��4*%����Wkw1�7@�ٕ%�/:���⑵��B�i�³���q�<�v����=��4~3?}{�Dv'8�Ӡ�v��Y�5WZ���y�<A����Q�.C�+�U��,ቐ����Y�0AEvd����i[��h���h�����j�o�z٠�R��IL�Wx^P���T��T�DQ���A4�����4Є=����B>�k�s�8t�S�ٿØ)U}�	�j�?lC�<C͗�3��3=�Y��eW�����Y�~�Z[23�ſ��H�����b@����7��mP4Ũ������(��Q28*���p����e���c$�)������"� ���Mݨ�u�ϛ�#4�BR��]|mkH�A]��جl����L�9����`q�6���{�p�F����|�!��='g��jɅ���@���nQz"T������ϲ�.�m�dх���z�<�X���o�?��e�
��{
���k-g��3[ꡥo��b�_A㔭��7<�<��v����&bF����dG������b�������X��(U'�V�s�:ȽQ/a��	�&�x��󲾣�k���� ��4,�)�v��4>	�\+×hi��钲_�����9e��4o�e���ӷ?�߭��)aO,������5n� ����4Z�F)�s
!=`akX+��ѭ����&��z���'^u�DЊV�dVKd���I�r�m���b�'���GQm�8��"�LKu��<J#�
lU��U6"��?/D������$o�LlO�O�D���
_�/8�%rWbrL1�-��O����rl='����v����.=~7�
��%���Z���V�|����I��ͧ{�0�>h���¹��7>����hN��M��B)z{7*ud�&'�	�ſ�P�y���A�$jz�����,���ſ�m� &�b�H؏��B��<1�iE,b���,&!A�q�����f���B��#��R��5�4������Fh[��Kz��1�&������"��|����@�r��:E|JbJ|RdKx��x��" ���H�DY�����I��s��*4"��B�H���x#|bM�����2��/?y�0��y#
��Ԧ"�mR
��w�B�����*Yz��z'�1�C��o�s�d;�[(�sa�?�b.5ݹ�v���L���0��]8w��;T̽~��DP��"t�v5�I��4�����Ŵ'��*�v�ꯩ��T��k�&���0�'B$��82�!�����p��|�Յ�|�X���|'�s���ͮ{�����	�����M8%?u "�!'���'�<4�7����H~3�+���n��$o~�W�_<�!H��He�а���ÆGFE�Ď9*���h�F?����r���4����N��?�C�O �b6���n5BAY���(�����0X��'�@L�ȧ0�pп=2!� �	���
%��
 �����
w�&�C@P��<�/���Lj`��#���b~Z��g킔�q��l�&��  j ��<�1},�?p9ҏ��I!���sꢏ��z�F�Z����$BO61̛��㺞� _&�WM� �5��i3�r`�����Д� B��o/�禢���g勐�h1��z����4��� P�������v��#VaE����q�Xt��0�~hKw�bR��٥D��̸��{m�ǧ�����g�����?$��ߟ�����i�޵
@D b�� d`Z L��� ,�� ��� <��x> ��? ��H �	�� |���E ��Z �@g z@�A�� � > )��� ����X��X��x& ��| v` ^�� ��S�  ��� \
�mB�h�5Z�V�U(�E��b4=��1�,ڌ����9�+��;��?C����� }�>BA�����)�]DCХ��w�O��E������3�?�dmѺuE˕�n�ڢ�E�b�ap��5�V<�f�ٹ�T���EkW�t]z�n|FZW�~C	�|��"$B$I���kHI����AǓRI�2��R#��&��kN	,{����
KV!)����b\��po,�;(�$��>�_�t����H��Ļ���C��
e�jHpȽ�ޮ?�xO_#�H�T��{^�s@���z�ՙP>�_ޚ
v_����Gҁk�
�'`-�s�[&m�٥�f������vd(����h,�����'�����
$��
>G-����z%k�B�\�����6G��������7�A�����8�3�H��>���x�c衬�����H����9~��I��FS6+��+\�ly�HR��
W��28g���~�xu�����C����r��؁!���^������:�?>!�G��Y�h[&7��e�X�����,9H�[��:g">��+z����^�c��N�
����M�2k�Zͬ-^�bF��gV��0W����+b�7�f��i�Y���G��1̺�EE%L�Tf�U�2
(�Ͼg
�[�W?>v�X
�I��m8]���ʈ��<�Ep��$���3w�-yl�ʕ%���q��$wi/z���۰�hI���k�kRS�T*N�[�ď�(�V�+�QE��#Zf&Ȳ���Y��y�+��u����g��1k7�^��4�Ν��,[�h� �D)��?mȚ��d^��s�ًt��FÌ%�����H�}&w�삹����2h0H_��))\]@��i��M���t�땅���p� O=���50�<1�D���ׅ+7���*^��x]њ��q�#��D������oX���;Y���m\��hT�8^�J�N��g늊�i|��Y�72��$�� �$t��{��ߌ<��E+Aq��	��
g��5�aA�}O�{t+]$�^�����R�aR�\T587�y@�~�G< �P6W�IH]���P4����e]���`J�Jc���Ϟ;]X�#]�s
=(>#�����|봻m�hߣ�H$Ex��z�[�{��~��"����E��AG�?�]~���*�N2(}�q�����vbL �������fA�?�`�����9Խ��@;.Ў�~�'�=���� �������z����2
�;��~�������{W��ؔ���]W�ũ4�?yG�ڵ��"�A�7�My��p��W����V��4\�s�g�޿72~�d"2Q�{~Rxx�i22>���\�z����|�޹�d����L5$�"��� ��-8�7�\i$EVBV!�9�|�{��X�����S���Ӏ�Eѷ):	�Y@ߠ��)z�7��<?��	.(<5>=�G��O��.l»�HM@�MW� UD���>��@<�U��9���\���|���ѫ��x��%)#ۦ�5�
u�ԙ���k����tr<����	�w.��x @u����A�1�S ��?y���>w"|��ي����������7ù�܆n+0�^�ܼ����*����O_*��0Mm�l)��$�"��WZ����)���K3�}I�v����x���]�*�ϡ%�l0�E�B�c�Mx�/D�L�� ���7A�oO.x�9��M7�d���.�
m�S$��Dv�w�n��	u_:�nF{G���%H&6Mg�l�j�\�\3_�6^�_W,���W��,�wQVH�Z�ـ��G���)O@�v�X<��������b�	\珊�i�!����3�W,�A8p�X�	a������?)�Cx����p�}Z���H��z�ֵl^՜c.��=O@��q�-U�s�]
�&z��T�W��������V�垕k�Z���A�N�q��d/����$��ք����qw����⟇�� ^u	��.����v�.~$�w��0������o�?.4�!��F�� ݒo}]�ڧ�ݾ�?�}�hE��һ�|�2�k;R��מ���|�����C��_m�o�?�9|��XXGO��&g8;�C9�C9�;"�ߌ�/�/+��'�-��^�ǖ�p)���ؖ�k�׌������*�|�����$��������,��{�>b!��U���R��޳�lߣ�&=�=d�Z��*3�f�Y�IVK�M�ߥ"���AW��IƯX�'t�]��ʮ��c`�~m�����Yx��p���Yx��'Xx���,<���,�P{}����[;;�A���BV/���5�દ��l:��6P�xz@��+�m�7�c߹�PX�^���J�_��*����9F�0��F2�5F�5�s��m��7}�|Y�>�M�e�Rk���f�ΘO��M���=�Bc�_���a�/6�'3~�1/��%����|�V�R�|R
W�@���+�Ϸ��nf��odIu�rB�_���yr5�p��r{}�����B&�����6�wm����/��?����)��F��=�v'Mk�J<���B2�+%K��>�c���&��pF���u-���
+qmd4��j"�l	Z'�&(�h,���Eլ�S��!F���,�U��5%5Y�ƕdB�2	�.�Mj���/�-
I~�b����?��0�X���(ө[z��I���?��wH�7x�߇T�<r�?SD�^��.}�,�����?O��^6��\~�9��%�))?>��Y� ���3���:?�K������g��?J�l�~v���S)��=�]�oK��s6O�f.�]����r{�96���C��Uz���{�1��{��ދ�/��2���2(��/�O���'g)��e�o<����\�y�"�ϟ�kY��Rzy>�c����x��6�Z,���g���={��G��;L�Fðg����&����gv͜ߡ�6�����,~]e|�_M-�-J�'�����$��jiim�bg^��Ze�_k�U�-�kZ׮����:#�+9��������
:q\�&Vk94�%��1��B6�=�T���呖$[���jV��2��P&G=�8~��bP4F�)5�������d@]0��}�����b�BP3/�1lDZ3��V���
��7芌mVˮzD�ix���q5�O2#K�A�;�f�&�z��7a$ـ�ә�<�a"#fS�޷t".��ӻÜ�IN�����3
lXZ�k�G�؄����^A�g��M�I`�y��W�d�u�J63*��J5��]�JW�U	(���O�F�a��?��j��%/�:I�g��YN�}�\Z�:id�0�V�j�ĭ�	a��
��5�GR-X�]#{���5�����1�k3�?_u�#��`j�s#����}�|/���n�a��c7����q`��gY���;��;Qjf�{l��_��e��2����h���_e�ϱ��m�r�����T_nGr�biF�۰����CƿI��ͭ��l�
|
���&����]�&������e��H8���G��yLKx�.J8�?��|�V�J�]$�m6�#.�����/����,��|���`S�τ������J���/�*�5�[����n3~�*�5�mn�z��)w¦�g�r��ֳ6�b��6�ߕ��c�eÿ�c]�f�����˄��z������Ǻ�<j�[�o���߱)�/l���