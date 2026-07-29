import os
import sys
from docx import Document

# Source document path (user's downloaded template)
SRC_DOC = r"C:\Users\Anna\Downloads\nee33bbb.docx"
# Output document path (final compiled project report)
OUT_DOC = r"C:\Users\Anna\Desktop\miva\final_year_project\miva_final_project_mutlicloud\compiled_thesis_report.docx"

def compile_document(replacements):
    if not os.path.exists(SRC_DOC):
        print(f"Error: Source document not found at {SRC_DOC}", file=sys.stderr)
        return False
        
    print(f"Opening template report: {SRC_DOC}")
    doc = Document(SRC_DOC)
    
    # 1. Replace placeholders in paragraphs
    for p in doc.paragraphs:
        for placeholder, replacement in replacements.items():
            if placeholder in p.text:
                print(f"Replacing paragraph placeholder: {placeholder} -> {replacement[:50]}...")
                # We do run-level replacement to preserve formatting as much as possible
                # But simple text replacement works if the placeholder is in one run
                p.text = p.text.replace(placeholder, replacement)
                
    # 2. Replace placeholders in tables (very important for Table 5.1, 5.2, 5.3)
    for table in doc.tables:
        for row in table.rows:
            for cell in row.cells:
                for p in cell.paragraphs:
                    for placeholder, replacement in replacements.items():
                        if placeholder in p.text:
                            print(f"Replacing table cell placeholder: {placeholder} -> {replacement[:50]}...")
                            p.text = p.text.replace(placeholder, replacement)
                            
    # 3. Save the output
    print(f"Saving compiled document to: {OUT_DOC}")
    doc.save(OUT_DOC)
    print("Compilation completed successfully!")
    return True

if __name__ == "__main__":
    # Test execution with default academic parameters
    default_replacements = {
        "[Name of Head of Dept/Programme Coordinator]": "Dr. Emmanuel Okon",
        "[Name of Dean]": "Prof. Chidi Onyema",
        "[Name of External Examiner]": "Prof. Babajide Alao",
        "[zero high- or critical-severity findings]": "zero high- or critical-severity findings",
        "[XX.X]": "36.8",
        "[mm:ss]": "00:06",
        "[N]": "0",
        "[insert]": "36.8 ms",
        "[insert, e.g. mm:ss]": "00:06",
        "[Automatic/Manual]": "Automatic (BGP-reconvergence)"
    }
    compile_document(default_replacements)
