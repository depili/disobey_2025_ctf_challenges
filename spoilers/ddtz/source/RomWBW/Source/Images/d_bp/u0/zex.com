�sZ3ENV  ZEX 2   DEBUG> NOISE> SHORT>LONG>ZEXMSG>�CCPCMD>�SILENCE> QUIETEXIT>�FLOW>�BELL>�PATH>�SCANCUR>�DU>   �s�1���͆������q��ͽ����
����)͊
�/
���ʹ
����	�B͈�Q���Ǘ�	� �Requires Z80!$*��K	"��� �0> 8=2���!    	��1� . "q.�~2s�: *|����o*
RSX image missing! �6*��K��Bo"�ɯ2��[�*�s#r*�s#r*|#~#fo"������:':-:5:=:F:Q:W:�2�!�� ��:��( *q.h~2t	~2u	~2v	~2w*�- �!q. ���:�� '*�###~� ##~�48 �v 
�n > �>�>�: �:�� X�K�! 	�[ s#r! 	�[ s#r�*� ѷ�R( !  �� ! �� ! �� ! ��(�[�! 	s#r6*q.�f. �[� ��.s#r�r+>w�*q.�w#r* #^#V*�.s#r*�DM." !! 	�[ Nwy#�:���:s�� *q.h>!w	w	w	w�~���>�*~#w*� ����ɯ2�! "�*��[����:�{ ;�}>{ 4���:�}(�
�^����
 ��^�6�"��[���R�:���O�AO:-
�y(�
�i͉ �}(�> �
�5�;ʰO�} >2�y�<2,
>� >��I�y���I�y�|�H͏�:��_�:8	�I:��i͆�:8	�I:��i��Q�� 2-
�i�� 	O�2-
y�i�� :-
�(	�2-
>��i>�2-
>��i�� ):.
�(�2.
2-
>��q>��i>�2.
2-
>��q>��i�� 
>�q>
�i���.!�^(#�$ ���Oy� ͂ �}�>�q����:�$(��:���:,
�����:�1�Q�:�Q�1�!��O 	�F
��
�5����;(��>;�vO:-
�y�#~͉(�+�� ͂�:���^�:�
 �͂���5�}>��I��Q�08$�:0 �02���!��0�>�(�(�q����q�!�:���e=�>� ��_ ^#V{�����[���R��گOq+��I�*�#"�!�6 �S����I� ���!�4���a��{�� ��	�� ��!�	�!���I"��I��(c�| (��!w	�!�(S8=�� >�I>
�q���(>�|�Q��^ ���
��q�t��$ ����q�����*��R+}�w�ѷ<���  �!��!���O�|7�y����(0̀�#(��  �(�	+~� #(�+~�(� (�~�# �#~< �<7��7��#~���!�	�!8O�| >2��| �y���7��7� �!�	�!8)O
�|( �|(x����G�0�G�x2��y���7��7�SAY �END SAY �" �' �WAIT RING �RING WAIT �WAIT �ABORT �QUIET ON �QUIET YES �QUIET OFF �QUIET NO �END QUIET �QUIET �SILENCE ON �SILENCE YES �SILENCE OFF �SILENCE NO �END SILENCE �SILENCE �AGAIN �CCPCMD ON �CCPCMD YES �CCPCMD OFF �CCPCMD NO �END CCPCMD �CCPCMD �ZEXMSG ON �ZEXMSG YES �ZEXMSG OFF �ZEXMSG NO �END ZEXMSG �ZEXMSG �FALSECMD ON �FALSECMD YES �FALSECMD NO �FALSECMD OFF �END FALSECMD �FALSECMD �IF TRUE �END IF �IF FALSE �ELSE �JOIN �RING �BELL �CR LF �CR LF 
TAB �SPACE �NUL �DEL ESC �UNTIL  ��WATCH FOR  ��PAUSE  �RING PAUSE  ��:��*�~���� 8�0
�g+> �g+�T+> �g+��+���(�ͼ*�!
�u*��*�
Hit any key... �  *�6��o& 6!�
�x2� �S�� (�́
(s#r#:���́
(͉ ��֯O����	��;�*~#~����o*
  ZEX Already Present
 �4͒)~�; #  ~#� �+�[��C����S�͒)6 �:�����o*
  ZEX cannot be rerun using GO.
 �4!� �� ���͖(1ͼ)2�ͦ)(&"|�)�(|�("x�##n& ��"��"�͵)���o*
  Aborting: inadequate ZCPR3 facilities.
 �A|�(��[	�R� ���)�K	! 	�~�!? 	^#V�S�##^#V�S�##^#V�S�* +++��R�i=�[	!" ~#fo"| 	"~##"�##"�!( "z�!��6 ����+"�"�"��:]��>�g+*�|�2��l!  "�>�2�ͼ**�#"��+>:�g+> �g+�
� �G*�6����~+�6#6
#"�"��!e ~� (�C #~�C #~�P ���!����!������)��o*
  No ZEX or SUB script file found.
 
�6e �~+��)!� �K*\ � :p�(	�Kq��):c� �	*=G:i O�(��:l� )���%��)�Z*��)� **��6�K*� 	"�6�K���B�0��@*�(��~����)�O��)��o*  TPA overflow �6*���[ ��R�8�+"�"���[�z=2�! �K����DM����N#��0:��w#z�(����*z~2�� *z~���o*
  ZEX  Version 5.0 
 �:] �/�:^ �/����o***  ZEX v.5.0     Syntax:  ZEX [ [dir:]subfile[.typ][ parameters] ]  **
$N            N-th command-line param.   '{' (col. 1) thru '}'  Comment lines 
$$, $| ...    Becomes '$','|'...         ;;    Remainder of line is a comment
'<' (1st char)  Input line to program    ^X    Control-char 'X' (any char.)
|ABORT|  Quit script                     |AGAIN|     Repeat script  
|WAIT|   Wait until a <CR> is typed      |RING WAIT| Ring bell, wait for <CR>

|PAUSE nn| or |RING PAUSE nn|     Wait nn secs. for keypress
|RING| or |BELL|     Ring console bell    
|UNTIL X|            Use console input until 'X' (any char.) is typed
|WATCHFOR string|    Use console input until "string" is output, then script
|JOIN|               Omit <CR> and continue on next line
|CR|, |LF|, |CR LF|, |NUL|, |SPACE|, |TAB|, |DEL|, |ESC|  The character(s) 

|CCPCMD|   / |CCPCMD OFF|    Show/ Don't show: CCP command output
|ZEXMSG|   / |ZEXMSG OFF|    Show/ Don't show: ZEX command prompt
|FALSECMD| / |FALSECMD OFF|  Show/ Don't show: commands in false flow state
|SILENCE|  / |SILENCE OFF|   Suppress/ resume: console output
|SAY|      / |END SAY|       Begin/ end:       direct message to console output
|"| = toggle |SAY|                  |'| = toggle |IF TRUE||SAY|
|IF TRUE| or |IF FALSE| / |END IF|  Do script if true(false) flow state
|IF TRUE| .. |ELSE| .. |END IF|     Do script per command flow state
synonyms: |... ON| or |... YES|  /  |... NO| or |... OFF| or |END ...| �A:5���:=O��:F"��ɷbk(~�|(�+w#�! ~�|��"w#�~�|(�"w#�! ~�|��+w#��A��[�� ��a��{�� �*|q###>�w�{��*���R"���F�o*
Directive c�F�o*
Parameter number out of range ;�F�o*
Expression or Parameter �F�o*
Script too long. ��o* Error Line #  *��+ͼ**��~�(#� �6 ��u*ͼ*�K�> (�g+��o*^ �6��o*
Too many parameters:  *��>	�6~�ȷ > ��g+�#��o*
Text Buffer Empty �4�o*
Incompatible RSX has altered (0001h). �4�ZEXSUB                                                                                                                                                                                                                                                                                                                                                                   �                                                                                                                                                                                                                                                                   �ÌÁ  u�  �     å�	����K                                               �                       ZEX v. 5.0  ͹7?���7�1�*" �r<(͹ *" �K �:���K���*#~#fo	��R�>�2�*:#6 ͹�*" * !Nwy#�* �����K ����%�K���!��4�!��4�  1��?!��^��^�'�_�Y�*8#�[Us#r�*:#6 ͆*4###�KD#~�(y� ���[@�*B�R��6;#��j#~#� ��*6:Fw�2W2R2]2^/2Q2Q2\��r+~͵���<��������������> ��$�$�.��N��F G�"O((��($:_�G(y��(:`� :Y���!X5��=2Y�x�:���'���(��N�'�F(�"(
!�~�6 �8�s�1��6(Q�(�� �"�"��O�"y�0�� �2b!:t� :Z��(��"�":a� ���>2a:a� (z-�(ˆ(:Z��(> 2`:`� ���>2`� (O�(K��O��8��8̈́(:^� �:]� �y�<�1̈́(:^� �:]� �:W�y(�?���*��'O:Z�� 
����<��� �����6>(2a2`�6y(2t��{�*I l& "X�:���*�. �*��6 (�((#:Z�� ���:Z��(�!_ˆ��ͷ�:b�(3��8>O !k	T]+���#q�b O	+�G� +�>2`�2b*:~��G(!�" y� 
2R/2Q2\:Q�(*6~� �� y� 2��*��G�?:T�(�$�(�'� �'����?:Z���!_�F�*:#�F+�*:�Fɷ_� !K^#V��agms������
39<CFLOUX^|�������6(	�> 2a�>2`��6(>��> ����6>(����!bwG#����w�>��'���(#� (����$� ͸��'��� ��*
�*�*�&̈́�*<~#fo~2Z�{͆!KP ���?å>�2Wɯ�>�*6wɯ�>�2Rɯ�>�2Qɯ�>�2Pɯ�>�2]ɯ2^�>�2^�:^2]/�>�2\ɯ�>	�O��> �> �2���G�͸> ���$�� ���'�>��:GG2����� � ����'![����2[�̈́<(:\/��:R��:W/���r+�{~2Z#~���2Z�{> 2a2`͆�'�r#~2Z�{�:S���3�8�P!�:H�(
= 
*6~�(�3!�!������:P��~#���O�*��*<~#fo�*>~#fo~��*>s#r��*8#~�(#�����
Cancel(y/n)?   Entire script(y/n)? 
[ZEX Cancelled]
 ZEX: Done
 �                                       �( �H          BA 		@  I$H� �B@B @ ��D�@ I   �"@@��$���@��	B @  I I���! �@DHI@H��  @ $ � � H$@�H ��
�������BD�HBII! �  D��!�   !"!D��BI	$ $"                                                  �                                                                                                                                                                                                                                                                   �	�    ZEX 5.0    �  Ò�uî���8                                               �                       1��_< �:���8͕�*-.�~��>�2�͊�>�2;  �	* !Nwy#�:/�(*-.h 0w	w	w	w* u��������8 �����8͕�!�!�!��!�  1��,!��K��K�'�_�Y�*8#�[Us#r�*:#6 �s*4###�KD#~�(y� ���[@�*B�R��6;#��W#~#� ��*6:Fw�2W2R2]2^/2Q2Q2\��_+~͢���)��������������> ��$�$����N��F G�O((��($:_�G(y��(:`� :Y���!X5��=2Y�x�:���'ͮ�(��N�'�F(�(
!�~�6 �%�s�1��#(Q��� ����O�y��� �2b!:t� :Z��(���:a� ͺ��>2a:a� (z-�ˆ(:Z��(> 2`:`� ͺ��>2`� (O�(K��O��8��8�q(:^� �:]� �y�)��q(:^� �:]� �:W�y(�,���*��'O:Z�� 
����)��� �����#>(2a2`�#y(2t��{�*I l& "X�:���*� �*���# (�(#:Z�� ���:Z��(�!_ˆ��ͤ�:b�(3��8>O !k	T]+���#q�b O	+�G� +�>2`�2b*:~��G(!� y� 
2R/2Q2\:Q�(*6~� �� y� 2��*��G�,:T�(�$�(�'� �'����,:Z���!_�F�*:#�F+�*:�Fɷ_� !8^#V��NTZ`t�������� &)039<BEKiory}���#(	�> 2a�>2`��#(>��> ����#>(����!bwG#����w�>��'���(#� (������$� ͥ��'��� ��*
�*�*��q�*<~#fo~2Z�h�s!KP ���,Ò>�2Wɯ�>�*6wɯ�>�2Rɯ�>�2Qɯ�>�2Pɯ�>�2]ɯ2^�>�2^�:^2]/�>�2\ɯ�>	�O��> �> �2���G�ͥ> ����$�� ���'�>��:GG2����� � ����'![����2[��q<(:\/��:R��:W/���_+�h~2Z#~���2Z�h> 2a2`�s�'�_#~2Z�h��:S��� �%�=!�:H�(
= 
*6~�(� !�!������:P��~#���O�*��*<~#fo�*>~#fo~��*>s#r��*8#~�(#�����
Cancel(y/n)?   Entire script(y/n)? 
[ZEX Cancelled]
 ZEX: Done
 �                                       �  �H         � H  �  �I D�� �  B @��$�B  H @ A D��$D @���@�H !H@AHD�$�	"BHB@�$@ @   IA �"A @UUUUUUUR� $@���BBH��H	 �@!$ �	$  		A" $$�HI! �!�@@                                                                      ����	*�C�+�C�+͵)�(
�ʹ*�< ~�(�l)�E)##(��C�+��)����K�+��)�K�+$���}2�+͵):�+�(�l)##��x� �y� ��������K�+~�$(=G#~+�$�O��*�+ ^#V������*�+ ~#fo~#fo~����" *�+~#fo����	 ��)��+ ��)*�+|�(~���*�+^#V#~�ѷ�"�+���	*�C�+����K�+��)������Y ʹ*Xʹ*����ʹ*�� ʹ*O�G��������ʹ*< ʹ*< ��������ʹ*���������� ���������w 	w#��������u*���� ~#�(3�	(��*�(��
(�(	� �y�(��y�G>�G�O> �g+�������� ����>�g+>
�g+���.	��*��: g��*�������*�g+��>^�g+��@�g+���� 0� ������
����O�y������'�4+��4+d �4+
 �4+}�8+������=+��0�g+�=<�R0�� �@(> ��ˀ7���ͻ+�g+�Ϳ+�g+����.�m+���O: g�}+������͓+�H 	�	���͜+	�	���H ͜+������|�8 }�8�������	�	�����Ɛ'�@'�!�+�}�($. ��                                           