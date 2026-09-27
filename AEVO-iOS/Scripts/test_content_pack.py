import copy
import json
import tempfile
import unittest
from pathlib import Path
from unittest.mock import patch
from validate_content_pack import ROOT, PackError, read, validate, quotas, schema_check
from create_learning_app import generate

class ContentPackTests(unittest.TestCase):
    def setUp(self): self.demo=validate(ROOT/'ContentPacks/demo-orbit',ROOT/'AppConfigs/orbit-demo.json')
    def invalid(self,file,change):
        with tempfile.TemporaryDirectory() as folder:
            target=Path(folder)
            for key,value in self.demo.items():
                value=copy.deepcopy(value)
                if key==file:change(value)
                (target/(key+'.json')).write_text(json.dumps(value))
            with self.assertRaises(PackError):validate(target)
    def test_both_packs_and_exact_aevo_ids(self):
        aevo=validate(ROOT/'ContentPacks/aevo-de',ROOT/'AppConfigs/aevo.json')
        baseline=read(ROOT/'Tests/Fixtures/aevo-content-ids.json')
        self.assertEqual(len(aevo['questions']),800);self.assertEqual(len(aevo['cards']),300)
        for k in ['questions','cards']:self.assertEqual([x['id'] for x in aevo[k]],baseline[k])
        self.assertEqual(len(self.demo['questions']),10);self.assertEqual(len(self.demo['cards']),5)
    def test_duplicate_question_and_option_ids(self):
        self.invalid('questions',lambda x:x[1].update(id=x[0]['id']))
        self.invalid('questions',lambda x:x[0]['options'][1].update(id=x[0]['options'][0]['id']))
    def test_missing_fields_invalid_types_and_version(self):
        self.invalid('questions',lambda x:x[0].pop('explanation'))
        self.invalid('questions',lambda x:x[0].update(type='essay'))
        self.invalid('cards',lambda x:x[0].update(version=0))
        self.invalid('manifest',lambda x:x.update(schemaVersion=99))
    def test_missing_objective_category_source_and_answer(self):
        self.invalid('questions',lambda x:x[0].update(competency='missing'))
        self.invalid('cards',lambda x:x[0].update(field=99))
        self.invalid('questions',lambda x:x[0].update(correctIDs=['absent']))
        self.invalid('sources',lambda x:x[0].update(url='javascript:alert(1)'))
    def test_bad_exam_count_weights_and_quota_rounding(self):
        self.invalid('exam_config',lambda x:x.update(questionCount=100))
        self.invalid('exam_config',lambda x:x['categoryWeights'][0].update(weight=0))
        self.invalid('exam_config',lambda x:x['categoryWeights'][0].update(categoryID=99))
        e=copy.deepcopy(self.demo['exam_config']);e['questionCount']=5
        self.assertEqual(quotas(e),{1:2,2:2,3:1})
    def test_unavailable_module_and_incomplete_template_rejected(self):
        self.invalid('manifest',lambda x:x['modules'].append('oralExam'))
        with self.assertRaises(PackError):validate(ROOT/'ContentPacks/_template')
    def test_json_schemas_reject_unknown_keys_and_bool_as_version(self):
        schema=read(ROOT/'Schemas/questions.schema.json')
        questions=copy.deepcopy(self.demo['questions']);questions[0]['typo']='oops'
        with self.assertRaises(PackError):schema_check(questions,schema,'questions')
        questions=copy.deepcopy(self.demo['questions']);questions[0]['version']=True
        with self.assertRaises(PackError):schema_check(questions,schema,'questions')
    def test_generator_never_overwrites_existing_output(self):
        with tempfile.TemporaryDirectory() as folder, patch('create_learning_app.swift_path',return_value='/unused/swift'):
            sentinel=Path(folder)/'keep.txt';sentinel.write_text('Eigene Arbeit')
            with self.assertRaises(PackError):generate(ROOT/'AppConfigs/orbit-demo.json',folder)
            self.assertEqual(sentinel.read_text(),'Eigene Arbeit')
    def test_generator_failure_leaves_no_finished_app(self):
        with tempfile.TemporaryDirectory() as folder, patch('create_learning_app.swift_path',return_value='/missing/compiler'):
            output=Path(folder)/'app'
            with self.assertRaises(OSError):generate(ROOT/'AppConfigs/orbit-demo.json',output)
            self.assertFalse(output.exists())
    def test_aevo_review_migration_is_structural_only(self):
        aevo=validate(ROOT/'ContentPacks/aevo-de');old=read(ROOT/'ContentInputs/Legacy_catalog.json')
        for q,prior in zip(aevo['questions'],old['questions']):
            q=dict(q);q.pop('type');self.assertEqual(q,prior)
        self.assertEqual(aevo['cards'],old['cards'])
    def test_runtime_has_no_subject_specific_labels_or_quota(self):
        for base in ['App','Core']:
            for file in (ROOT/base).glob('*.swift'):
                code=file.read_text()
                self.assertNotIn('1...4',code,str(file))
                for word in ['AEVO','aevo.','Handlungsfeld','Ausbilderschein']:
                    self.assertNotIn(word,code,str(file))
if __name__=='__main__':unittest.main()
