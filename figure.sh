git clone https://github.com/dfalster/baad
rm -rf baad_pre baad_post

REF=220272b79ceb3aa792523b0c66629be0f23d4468

git clone baad baad_post
git clone baad baad_pre

git -C baad_post checkout -b work $REF
git -C baad_pre checkout -b work "${REF}^"

cp make_report.R baad_pre/reports
cp make_report.R baad_post/reports

make -C baad_pre baad
make -C baad_post baad

Rscript -e "source('baad_pre/reports/make_report.R', chdir=TRUE)"
Rscript -e "source('baad_post/reports/make_report.R', chdir=TRUE)"

open baad_pre/reports/output/report-by-study/Kitazawa1959.html
open baad_post/reports/output/report-by-study/Kitazawa1959.html

Rscript figure.R
